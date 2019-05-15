using NCDatasets
using Dates
using Glob
using PyPlot
using DIVAnd
include("mergingclim.jl")

figdir = "./figures/"
plotcheck = 0
ioff()

# User inputs
# ------------

varname = "chlorophyll-a"
var_stdname = "mass_concentration_of_chlorophyll_a_in_sea_water"
product_id = "e61d12cd-837f-49ff-a0e1-3a694ab84bc5"
outputdir = "/data/EMODnet/Chemistry/merged/"
databasedir = "/data/EMODnet/Chemistry/prod/"

# Grid and resolutions
Δlon = 0.5
Δlat = 0.5
longrid = -40.:Δlon:55.
latgrid = 24.:Δlat:67.
depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200, 250, 300, 400,
500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1750, 2000,
2500, 3000]);

depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200, 250, 300]);

# Notes on depth levels:
# Arctic: 300 m
# Atlantic: 300 m
# Baltic: 30 m
# Black: 50 m
# Mediterranean: 1000 m
# North: 500 m

# Time grid defined from list of years and months
yearrange = collect(1993:2015)
monthlist = [2,5,8,11]
dateref = Date(1900,1,1)
timegrid = create_date_list(yearrange, monthlist)

if !(isdir(outputdir))
	@info("Create new output directory")
	mkpath(outputdir)
else
	@info("Output directory already exists")
end
outputfile = joinpath(outputdir, "Water_body_$(varname)_combined.nc")
outputtitle = "DIVA 4D analysis of Water_body_$(varname)";

@info("Creating new netCDF file for the new grid")
@info("inside directory: $(outputdir)")
create_nc_merged(outputfile, longrid, latgrid, depthgrid, timegrid);

@info "Getting the years from the output file"
yeargrid = get_years(joinpath(outputdir, outputfile));
@show yeargrid;

# Loop on the seasons
# TODO: work on all the seasons
for season in ["Winter",] # "Spring", "Summer", "Autumn"]

	@info("Working on season $(season)")

	# Generate list of files for that season and that variable
	filelist = get_file_list(databasedir, varname, season);
	@info("Found $(length(filelist)) files")

	# Loop on the depths
	for (idepth, depthtarget) in enumerate(depthgrid)
		@debug("Working on depth $(depthtarget)")

		# Loop on years
		for (iyear, years) in enumerate(yeargrid)
			@info("Working on year $(years)")

			# Loop on the regions (using the file list)
			iregion = 0

			# Prepare the figure
			if plotcheck == 1
				fig = figure()
				lonlist2plot = []
				latlist2plot = []
				fieldlist2plot = []
			end

			# Create a 3D array that will be used for the merging
			sz = (length(longrid), length(latgrid), length(filelist))
			fields2merge = fill(NaN, sz)

			for regionfile in filelist
				iregion += 1
				@debug("Working on region $(regionfile)")
				@debug("Depth index: $(idepth) -- time index: $(iyear)")

				# Get the years available in the regional file
				yearregion, lonregion, latregion, depthregion = get_coords(regionfile)
				@debug(typeof(lonregion), size(lonregion));
				@debug(typeof(latregion), size(latregion));

				@info("Depth range: $(minimum(depthregion))--$(maximum(depthregion)) m");

				# find in the variable the time index
				# corresponding to the year

				yearindex = findall(years .== yearregion)
				if length(yearindex) == 0
					@debug "Year $(years) not available in the file, processing next region"
				else
					@info "Year $(years) is available, will perform vertical extraction"
					@debug "Year index: $(yearindex)"

					# Check if the considered depth lies within the depth interval
					# of the considered file
					if (depthtarget >= minimum(depthregion) &&
						depthtarget <= maximum(depthregion))

						# Read the field at the good year index
						@debug("Reading variable for selected year $(years)")

						if length(findall(depthregion .== depthtarget)) == 0
							@info("Depth not found, will perform vertical interpolation")
							dmin, dmax = get_closer_depth(depthregion, depthtarget)
							w1, w2 = get_depth_weights(depthtarget, dmin, dmax)
							indmin, indmax = get_depth_indices(depthtarget, depthregion)

							# Select the variable according to the standard name, which should be
							# (fingers crossed) unique
							field_depth = get_var_level_time(var_stdname, regionfile, [indmin, indmax], yearindex)
							@debug(size(field_depth))
							field_depth_interpolated = w1 * field_depth[:,:,1] +
							w2 * field_above[:,:,2];
						else
							@info("Depth is found, we use it without interpolation")
							depthindex = findall(depthregion .== depthtarget)[1]
							field_depth_interpolated = get_var_level_time(var_stdname, regionfile, depthindex, yearindex)
						end
						@info("Size of the interpolated field: $(size(field_depth_interpolated))");

						#field2interp_horiz = dropdims(field_depth_interpolated[:,:,yearindex], dims=3)
						@debug("Performing 2D horizontal interpolation")
						loninterp, latinterp, finterp, indlon, indlat = interp_horiz(lonregion, latregion,
						field_depth_interpolated, longrid, latgrid);

						@debug("Filling the 3D array for merging")
						fields2merge[indlon, indlat, iregion] = coalesce.(finterp, NaN);

						if plotcheck == 1
							# Gather the coordinates and fields into lists
							push!(lonlist2plot, loninterp)
							push!(latlist2plot, latinterp)
							push!(fieldlist2plot, finterp)
						end

					else
						@warn("The depths in the regional product don't include the depth level $(depthtarget) m")
					end
				end
			end # end of loop on the regions

			@info("Merging the domains using `DIVAnd.hmerge`")
			field_merged = DIVAnd.hmerge(fields2merge,4.0);
			@info("Size of the merged field: $(size(field_merged))");

			# Write inside the global netCDF file
			dsout = Dataset(outputfile, "a")
			dsout["Water_body_ammonium"][1:length(longrid),1:length(latgrid),idepth,iyear] = field_merged;
			close(dsout)

			# Make a plot for checking if it works
			if plotcheck == 1
				@info "Creating plot for checking"

				#TODO adapt the extremal values for the plot
				vmin = 0.
				vmax = 1.

				# Loop on the regional fields that were re-interpolated
				for (lon2plot, lat2plot, field2plot) in zip(lonlist2plot, latlist2plot, fieldlist2plot)

					@debug("Extremal values: $(vmin), $(vmax)")
					#PyPlot.pcolormesh(lonregion, latregion, permutedims(field2interp_horiz_nomiss, [2,1]),
					#vmin=vmin, vmax=vmax)
					PyPlot.pcolormesh(lon2plot, lat2plot, permutedims(coalesce.(field2plot, NaN), [2,1]),
					vmin=vmin, vmax=vmax)
				end
				colorbar()
				title("$(varname), $(season) $(years) at $(depthtarget) m")
				figname = joinpath(figdir, "$(varname)-$(season)-$(depthtarget)-$(years).png")
				@info "Saving figure as $(figname)"
				PyPlot.savefig(figname)
				PyPlot.close()

				@info("Plotting the merged field on the full grid")
				PyPlot.pcolormesh(longrid, latgrid, permutedims(field_merged, [2,1]),
				vmin=vmin, vmax=vmax)
				colorbar()
				title("$(varname), $(season) $(years) at $(depthtarget) m")
				figname = joinpath(figdir, "$(varname)-$(season)-$(depthtarget)-$(years)_merged.png")
				@info "Saving figure as $(figname)"
				PyPlot.savefig(figname)
				PyPlot.close()

			end
		end # end of loop on the years
	end # end of loop on the depth levels
end # end of loop on the seasons

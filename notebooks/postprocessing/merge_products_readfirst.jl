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

# List of depths: no product with
depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200, 250, 300]);

# Time grid defined from list of years and months
yearmin = 2006;
yearmax = 2010;
yearrange = collect(yearmin:yearmax)
monthlist = [2,5,8,11]
dateref = Date(1900,1,1)
timegrid = create_date_list(yearrange, monthlist)

if !(isdir(outputdir))
	@info("Create new output directory")
	mkpath(outputdir)
else
	@info("Output directory already exists")
end
outputfile = joinpath(outputdir, "Water_body_$(varname)_combined_test.nc")
outputtitle = "DIVA 4D analysis of Water_body_$(varname)";

@info("Creating new netCDF file for the new grid")
@info("inside directory: $(outputdir)")
create_nc_merged(outputfile, longrid, latgrid, depthgrid, timegrid);

@info "Getting the years from the output file"
yeargrid = get_years(joinpath(outputdir, outputfile));
@show yeargrid;

# Create a specific structure to store the data of a climatology
struct RegionClimato
	name::String
	years::Array{Int64,1}
	depths::Array{Float32,1}
	lons::Array{Float32,1}
	lats::Array{Float32,1}
	field::Array{Union{Missing, Float32},4}
end

# Loop on the seasons
for season in ["Winter",] # "Spring", "Summer", "Autumn"]

	@info("Working on season $(season)")

	# Generate list of files for that season and that variable
	filelist = get_file_list(databasedir, varname, season);
	@info("Found $(length(filelist)) files")

	global climlist = []

	for datafile in filelist
		@info "Reading data from file $(datafile)"
		regionname = get_region_name(datafile);
		yeargridregion, lonregion, latregion, depthregion = get_coords(datafile)
		@info("minimum year for the region: $(minimum(yeargridregion)), maximum year: $(maximum(yeargridregion))");
		@debug "Year grid for the region: $(yeargridregion)";

		# Select the good years according to target grid
		goodyears = (yeargridregion .>= yearmin) .& (yeargridregion .<= yearmax);
		# Select good depths according to target
		gooddepths = (depthregion .>= minimum(depthgrid)) .&
		(depthregion .<= maximum(depthgrid));

		# Loading the field only in the region and for the period of interest
		Dataset(datafile, "r") do ds1
			global field_subset
			field = varbyattrib(ds1, standard_name=var_stdname)[1][:,:,:,:]
			@debug("Before subsetting: $(size(field))")
			field_subset = field[:,:,gooddepths,goodyears]
			@debug("After subsetting: $(size(field_subset))")
		end
		@info(typeof(field_subset))
		clim = RegionClimato(regionname, yeargridregion[goodyears],
		depthregion[gooddepths], lonregion, latregion, coalesce.(field_subset))
		push!(climlist, clim)
		@info(size(clim.field))
	end
	@info(size(climlist))
	@info("Finished reading climatologies")

	# Now we have all the climatologies in a list `climlist`

	# Loop on the depths
	for (idepth, depthtarget) in enumerate(depthgrid)
		@info("Working on depth $(depthtarget)")

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

			for clim in climlist
				iregion += 1
				@debug("Working on $(clim.name) region")
				@debug("Depth index: $(idepth) -- time index: $(iyear)")

				# find in the variable the time index
				# corresponding to the year

				yearindex = findall(years .== clim.years)
				@show clim.years
				if length(yearindex) == 0
					@debug "Year $(years) not available in the file, processing next region"
				else
					@info "Year $(years) is available"
					@info "Year index: $(yearindex)"
				end

				# Check if the considered depth lies within the depth interval
				# of the considered file
				if (depthtarget >= minimum(clim.depths) &&
					depthtarget <= maximum(clim.depths))

					# Read the field at the good year index
					@debug("Reading variable for selected year $(years)")

					if length(findall(clim.depths .== depthtarget)) == 0
						@warn("Depth not found, will perform vertical interpolation")
						dmin, dmax = get_closer_depth(clim.depths, depthtarget)
						w1, w2 = get_depth_weights(depthtarget, dmin, dmax)
						@show (w1, w2);
						@show depthtarget;
						@show typeof(clim.depths)
						indmin, indmax = get_depth_indices(depthtarget, clim.depths)


						field_depth = clim.field[:,:,[indmin, indmax],yearindex]
						@debug(size(field_depth))
						field_depth_interpolated = w1 * field_depth[:,:,1] +
						w2 * field_depth[:,:,2];
					else
						@info("Depth is found, we use it without interpolation")
						depthindex = findall(clim.depths .== depthtarget)[1]
						@show depthindex;
						@show yearindex[1];
						@show size(clim.field);
						field_depth_interpolated = clim.field[:,:,depthindex,yearindex[1]]

					end
					@info("Size of the interpolated field: $(size(field_depth_interpolated))");

					@debug("Performing 2D horizontal interpolation")
					loninterp, latinterp, finterp, indlon, indlat = interp_horiz(clim.lons, clim.lats,
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
			# @info("Merging the domains using `DIVAnd.hmerge`")
			# field_merged = DIVAnd.hmerge(fields2merge,4.0);
			# @info("Size of the merged field: $(size(field_merged))");
			#
			# # Write inside the global netCDF file
			# dsout = Dataset(outputfile, "a")
			# dsout["Water_body_ammonium"][1:length(longrid),1:length(latgrid),idepth,iyear] = field_merged;
			# close(dsout)

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
			end # end of plotting
		end # end of loop on the years
	end # end of loop on the depth levels
end # end of loop on the seasons

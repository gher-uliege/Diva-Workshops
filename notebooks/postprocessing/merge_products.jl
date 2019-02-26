using NCDatasets
using Dates
using Glob
using PyPlot
using DIVAnd
include("mergingclim.jl")

figdir = "./figures/"
plotcheck = 1
ioff()

# User inputs
# ------------

varname = "chlorophyll-a"
var_stdname = "mass_concentration_of_chlorophyll_a_in_sea_water"
product_id = "e61d12cd-837f-49ff-a0e1-3a694ab84bc5"
outputdir = "/data/EMODnet/Chemistry/merged/"
databasedir = "/data/EMODnet/Chemistry/prod/"

# Grid and resolutions
Δlon = 1.
Δlat = 1.
longrid = -40.:Δlon:55.
latgrid = 24.:Δlat:67.
depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200, 250, 300, 400,
500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1750, 2000,
2500, 3000]);

depthgrid = depthgrid[1:6];

# Time should be generated from years and seasons maybe
timegrid = [23787, 23876, 23968, 24060, 24152, 24241, 24333, 24425, 24517, 24606,
24698, 24790, 24882, 24972, 25064, 25156, 25248, 25337, 25429, 25521,
25613, 25702, 25794, 25886, 25978, 26067, 26159, 26251, 26343, 26433,
26525, 26617, 26709, 26798, 26890, 26982, 27074, 27163, 27255, 27347,
27439, 27528, 27620, 27712, 27804, 27894, 27986, 28078, 28170, 28259,
28351, 28443, 28535, 28624, 28716, 28808, 28900, 28989, 29081, 29173,
29265, 29355, 29447, 29539, 29631, 29720, 29812, 29904, 29996, 30085,
30177, 30269, 30361, 30450, 30542, 30634, 30726, 30816, 30908, 31000,
31092, 31181, 31273, 31365, 31457, 31546, 31638, 31730, 31822, 31911,
32003, 32095, 32187, 32277, 32369, 32461, 32553, 32642, 32734, 32826,
32918, 33007, 33099, 33191, 33283, 33372, 33464, 33556, 33648, 33738,
33830, 33922, 34014, 34103, 34195, 34287, 34379, 34468, 34560, 34652,
34744, 34833, 34925, 35017, 35109, 35199, 35291, 35383, 35475, 35564,
35656, 35748, 35840, 35929, 36021, 36113, 36205, 36294, 36386, 36478,
36570, 36660, 36752, 36844, 36936, 37025, 37117, 37209, 37301, 37390,
37482, 37574, 37666, 37755, 37847, 37939, 38031, 38121, 38213, 38305,
38397, 38486, 38578, 38670, 38762, 38851, 38943, 39035, 39127, 39216,
39308, 39400, 39492, 39582, 39674, 39766, 39858, 39947, 40039, 40131,
40223, 40312, 40404, 40496];


if !(isdir(outputdir))
	@info("Create new output directory")
	mkpath(outputdir)
else
	@info("Output directory already exists")
end
outputfile = joinpath(outputdir, "Water_body_$(varname)_combined.nc")
outputtitle = "DIVA 4D analysis of Water_body_$(varname)";

@info("Creating new netCDF file for the new grid")
create_nc_merged(outputfile, longrid, latgrid, depthgrid, timegrid);

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
	for depthtarget in depthgrid
		@debug("Working on depth $(depthtarget)")

		# Loop on years
		# TODO: test on all the years
		for years in yeargrid[end-10:end-5]
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
							@info("Depth not found, will perform interpolation")
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
						@info(size(field_depth_interpolated));

						#field2interp_horiz = dropdims(field_depth_interpolated[:,:,yearindex], dims=3)
						@debug("Performing 2D interpolation")
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
			@info(size(field_merged));

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

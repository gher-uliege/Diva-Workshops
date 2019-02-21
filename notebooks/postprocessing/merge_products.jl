using NCDatasets
using Dates
using Glob
include("mergingclim.jl")

Δlon = 1.
Δlat = 1.
longrid = -40.:Δlon:55.
latgrid = 24.:Δlat:67.
depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200, 250, 300, 400,
500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1750, 2000,
2500, 3000]);
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

varname = "chlorophyll-a"
product_id = "e61d12cd-837f-49ff-a0e1-3a694ab84bc5"
outputdir = "/data/EMODnet/Chemistry/merged/"
databasedir = "/data/EMODnet/Chemistry/prod/"

if !(isdir(outputdir))
	@info("Create new output directory")
	mkpath(outputdir)
else
	@info("Output directory already exists")
end
outputfile = joinpath(outputdir, "Water_body_$(varname)_combined.nc")
outputtitle = "DIVA 4D analysis of Water_body_$(varname)";

@info("Creating new file for the new grid")
create_nc_merged(outputfile, longrid, latgrid, depthgrid, timegrid);

yeargrid = get_years(joinpath(outputdir, outputfile));
@show yeargrid;

# Loop on the seasons
for season in ["Winter",] # "Spring", "Summer", "Autumn"]

	@info("Working on season $(season)")

	# Generate list of files for that season and that variable
	filelist = get_file_list(databasedir, varname, season);
	@info("Found $(length(filelist)) files")

	# Loop on the depths
	for depth in depthgrid
		@debug("Working on depth $(depth)")

		# Loop on the regions (using the file list)
		for regionfile in filelist
			@debug("Working on region $(regionfile)")

			# Read years and depths from the file
			ds1 = Dataset(regionfile, "r")
			depthregionvector = ds1["depth"][:]
			close(ds1)

			# Remove the missing values
			depthregionvector = coalesce.(depthregionvector, NaN);
			yearlistregion = get_years(regionfile);

			@info("Minimal depth: $(minimum(depthregionvector))");
			@info("Maximal depth: $(maximum(depthregionvector))");

			# Check if the considered depth lies within the depth interval
			# of the considered file
			if depth >= minimum(depthregionvector) && depth <= minimum(depthregionvector)
				# Find the indices for that depth and that time
				if length(findall(depthregionvector .== depth)) == 0
					@info("Depth not found, will perform interpolation")
					dmin, dmax = get_closer_depth(depthregionvector, depth)
					w1, w2 = get_depth_weights(depth, dmin, dmax)
					indmin, indmax = get_depth_indices(depth, depthregionvector)

					# Select the variable according to the standard name, which should be
					# (fingers crossed) unique
					ds1 = Dataset(regionfile, "r")
					fieldinterp = varbyattrib(ds1, standard_name = "mass_concentration_of_chlorophyll_a_in_sea_water")[1][:,:,indmin:indmax,:];
					close(ds1)
					@info(size(fieldinterp));

				else
					@info("Depth is found, we use it without interpolation")
					depthindex = findall(depthregionvector .== depth)[1]
				end

				# Loop on years
				for years in yeargrid[1:5]
					@info("Working on year $(years)")
				end

			else
				@info("The depths in the regional product don't include the depth level $(depth) m")
			end

		end
	end
end

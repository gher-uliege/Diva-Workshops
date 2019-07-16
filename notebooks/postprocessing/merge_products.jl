using NCDatasets
using Dates
using Glob
using DIVAnd
include("mergingclim.jl")

plotcheck = false

if plotcheck
	@info("Will create plots for checking")
	figdir = "./figures/"
	using PyPlot
end

# User inputs
# ------------

varname = "chlorophyll-a"
var_stdname = "mass_concentration_of_chlorophyll_a_in_sea_water"
longname = "chlorophyll-a"
units = "mg/m^3"


#varname = "silicate"
#longname = "Water body silicate"
#var_stdname = "mass_concentration_of_silicate_in_sea_water"
units = "umol/l"

#varname = "oxygen_concentration"
#longname = "Water body dissolved oxygen concentration"
#var_stdname = "mass_concentration_of_oxygen_in_sea_water"
#units = "umol/l"

#varname = "phosphate"
#longname = "Water body phosphate"
#var_stdname = "mass_concentration_of_phosphate_in_sea_water"
#units = "umol/l"

#varname = "nitrogen"
#longname = "Water_body_dissolved_inorganic_nitrogen"
#var_stdname = "mass_concentration_of_inorganic_nitrogen_in_sea_water"
#units = "umol/l"


product_id = ""

hostname = gethostname()
if hostname == "ogs01"
	@info "Working in production server"
	outputdir = "/production/apache/data/emodnet-test-charles/merged"
	databasedir = "/production/apache/data/emodnet-domains/"
elseif hostname == "GHER-ULg-Laptop"
	outputdir = "/data/EMODnet/Chemistry/merged/"
	databasedir = "/data/EMODnet/Chemistry/prod/"
else
	@error("Unknown host")
end

# Grid and resolutions
deltalon = 0.1
deltalat = 0.1
longrid = -40.:deltalon:55.
latgrid = 24.:deltalat:67.

# List of depths: selected as the union of the different products
depthgrid = Float64.([0, 5, 10, 20, 30, 40, 50, 75, 100, 125, 150, 200,
                      250, 300, 400, 500, 600, 700, 800, 900, 1000]);

# Time grid defined from list of years and months
yearmin = 1983;
yearmax = 2016;
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
outputfile = joinpath(outputdir, "Water_body_$(varname)_combined_V1.nc")
outputtitle = "DIVA 4D analysis of Water_body_$(varname)";

if isfile(outputfile)
	@warn("Removing existing output file")
	rm(outputfile)
end

@info("Creating new netCDF file for the new grid")
@info("inside directory: $(outputdir)")
valex = -999.

title = "Water body $(varname)"
create_nc_merged(outputfile, longrid, latgrid, depthgrid, timegrid,
				 varname, var_stdname, longname, title, units, valex);

@info "Getting the years from the output file"
yeargrid = get_years(joinpath(outputdir, outputfile));
@debug "Year grid: $(yeargrid)";

# Loop on the seasons
for (iseason, season) in enumerate(["Winter", "Spring", "Summer", "Autumn"])

	@info("Working on season $(season)")

	# Generate list of files for that season and that variable
	filelist = get_file_list(databasedir, varname, season);
	nfiles = length(filelist);
	@info("Found $(nfiles) files")
	if nfiles !== 6
		@warn("6 files expected, only found $(nfiles)")
	end

	global climlist = []

	for datafile in filelist
		@info "Reading data from file $(datafile)"
		regionname = get_region_name(datafile);
		yeargridregion, lonregion, latregion, depthregion = get_coords(datafile)
		@info("minimum year for the region: $(minimum(yeargridregion)), maximum year: $(maximum(yeargridregion))");
		@debug "Year grid for the region: $(yeargridregion)";

		@info("minimum depth for the region: $(minimum(depthregion)), maximum year: $(maximum(depthregion))");
		@debug(depthregion);

		# Select the good years according to target grid
		goodyears = (yeargridregion .>= yearmin) .& (yeargridregion .<= yearmax);
		# Select good depths according to target
		gooddepths = (depthregion .>= minimum(depthgrid)) .&
		(depthregion .<= maximum(depthgrid));

		# Loading the field only in the region and for the period of interest
		Dataset(datafile, "r") do ds1
			global field_subset, field_masked05_subset
			field = varbyattrib(ds1, standard_name=var_stdname)[1][:,:,:,:]
			field_masked05 = varbyattrib(ds1, standard_name=var_stdname)[3][:,:,:,:]
			@debug("Before subsetting: $(size(field))")
			field_subset = field[:,:,gooddepths,goodyears]
			field_masked05_subset = field_masked05[:,:,gooddepths,goodyears]
			@debug("After subsetting: $(size(field_subset))")
		end
		@info(typeof(field_subset))
		clim = RegionClimato(regionname, yeargridregion[goodyears],
		depthregion[gooddepths], lonregion, latregion,
		coalesce.(field_subset), coalesce.(field_masked05_subset))
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
			fields_masked2merge = fill(NaN, sz)

			for clim in climlist
				iregion += 1
				@debug("Working on $(clim.name) region")
				@debug("Depth index: $(idepth) -- time index: $(iyear)")

				# find in the variable the time index
				# corresponding to the year

				yearindex = findall(years .== clim.years)
				@debug(clim.years)
				if length(yearindex) == 0
					@debug "Year $(years) not available in the file, processing next region"
				else
					@info "Year $(years) is available, year index: $(yearindex[1])"

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
							fieldmasked_depth = clim.fieldmasked[:,:,[indmin, indmax],yearindex]

							@debug(size(field_depth))
							field_depth_interpolated = w1 * field_depth[:,:,1] +
							w2 * field_depth[:,:,2];
							fieldmasked_depth_interpolated = w1 * fieldmasked_depth[:,:,1] +
							w2 * fieldmasked_depth[:,:,2];
						else
							@info("Depth is found, we use it without interpolation")
							depthindex = findall(clim.depths .== depthtarget)[1]

							@debug depthindex;
							@debug yearindex[1];
							@info(size(clim.field));
							field_depth_interpolated = clim.field[:,:,depthindex,yearindex[1]]
							fieldmasked_depth_interpolated = clim.fieldmasked[:,:,depthindex,yearindex[1]]
						end
						@info("Size of the interpolated field: $(size(field_depth_interpolated))");

						@debug("Performing 2D horizontal interpolation")
						loninterp, latinterp, finterp, indlon, indlat = interp_horiz(clim.lons, clim.lats,
						field_depth_interpolated, longrid, latgrid);

						_, _, finterp_masked, _, _ = interp_horiz(clim.lons, clim.lats,
						fieldmasked_depth_interpolated, longrid, latgrid);

						@debug("Filling the 3D array for merging")
						fields2merge[indlon, indlat, iregion] = coalesce.(finterp, NaN);
						fields_masked2merge[indlon, indlat, iregion] = coalesce.(finterp_masked, NaN);

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
			end
			@info("Merging the domains using `DIVAnd.hmerge`")
			field_merged = DIVAnd.hmerge(fields2merge,4.0);
			field_masked_merged = DIVAnd.hmerge(fields_masked2merge,4.0);
			@info("Size of the merged field: $(size(field_merged))");

			@info("Setting the missing value for the variable")
			nanmask = isnan.(field_merged)
			field_merged[nanmask] .= valex;

			nanmask = isnan.(field_masked_merged)
			field_masked_merged[nanmask] .= valex;

			@debug("Time index in the netCDF: $((iyear-1)*4+iseason)")
			# Write inside the global netCDF file
			dsout = Dataset(outputfile, "a") do dsout
				dsout
				dsout[varname][1:length(longrid),1:length(latgrid),idepth,(iyear-1)*4+iseason] = field_merged;
				dsout[varname*"_L2"][1:length(longrid),1:length(latgrid),idepth,(iyear-1)*4+iseason] = field_masked_merged;
			end

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
	iseason += 1
end # end of loop on the seasons
@info("Merged climatology written in file $(outputfile)")

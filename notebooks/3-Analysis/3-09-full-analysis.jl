### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 6b965927-0eb7-4db1-adef-f32d9fca9ca0
begin
	using DrWatson
	import Pkg
	Pkg.activate("Diva-Workshops")
	Pkg.instantiate()
	Pkg.add(url="https://github.com/gher-uliege/DIVAnd.jl", rev="master")
	Pkg.add(Pkg.PackageSpec(name="PhysOcean", rev="master"))
	import Pkg; Pkg.add("DataStructures")
	using NCDatasets
	using PhysOcean
	using Downloads
	using DataStructures
	using DIVAnd
	using Dates
	using Statistics
	using Random
	using PhysOcean
	using Makie, CairoMakie, GeoMakie
	include("../config.jl")
end

# ╔═╡ b2386b36-3f8f-4a1a-b08f-9f654d2059af
md"""
# DIVAnd full analysis

This [Pluto](https://plutojl.org/) notebook presents the different steps necessary for the creation of a climatology:
 
1. ODV data reading.
2. Extraction of bathymetry and creation of land-sea mask
3. Data download from other sources and duplicate removal.
4. Quality control.
5. Parameter optimisation.
6. Spatio-temporal interpolation with DIVAnd.

This workflow is similar to the one from the Jupyter notebook `3-09-full-analysis.ipynb`.

## 📦📦 Import packages
"""

# ╔═╡ 55f04355-fabf-4ace-bba5-048b07c2abf2
md"""
## ⚙️ Configuration
- Create the grid (`lonr`, `latr`)
- Define the vertical (depth) levels (`depthr`)
- Define the time periods (`yearlist` and `monthlist`).
- Select the variable of interest (`varname`)
"""

# ╔═╡ 98df5c0f-3810-41ed-8b4a-ec087bd03370
begin
	dx, dy = 0.125, 0.125
	lonr = 11.5:dx:20
	latr = 39:dy:46
	timerange = [Date(1950,1,1), Date(2017,12,31)];
	
	depthr = [0.,5., 10., 15., 20., 25., 30., 40., 50., 66, 
	    75, 85, 100, 112, 125, 135, 150, 175, 200, 225, 250, 
	    275, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 
	    800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 
	    1300, 1350, 1400, 1450, 1500, 1600, 1750, 1850, 2000];
	
	depthr = [0.,10.,20.];
	
	varname = "Salinity"
	yearlist = [1900:2017];
	monthlist = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]];
end

# ╔═╡ bde7863c-fad3-4416-92df-aea60e50e6e5
md"""
We create here the variable `TS` (for "time selector"), which allows us to
work with the observations corresponding to each period of interest        
(defined via the variables (`yearlist` and `monthlist`).
"""

# ╔═╡ f0982375-9b50-452d-9c2d-c530c2ad7aa4
begin 
	TS = DIVAnd.TimeSelectorYearListMonthList(yearlist, monthlist);
	@show TS;
end		

# ╔═╡ bde1f534-318b-4709-b817-9dc4dfe2bd4c
md"""
## 📁 Read the (input) ODV file

Adapt the datadir and datafile values. The example is based on a sub-setting
of the Mediterranean Sea aggregated dataset. The dataset has been extracted
around the Adriatic Sea and exported to a netCDF using Ocean Data View. <img
src="./Images/MedSeaAggreg.jpg" width="450px">

Download the data files (test and full) if needed.
"""

# ╔═╡ c7e43d03-6b21-4df8-9008-1f32a4bb37c9
begin 
	datafile = joinpath(datadir(), "AdriaticSea_SDC.nc")
	download_check(datafile, adriaticfileURL)
end

# ╔═╡ 0434458f-ce8c-4814-a8aa-de6fc35c21e0
md"""
### Read  and plot the observations
"""

# ╔═╡ 3d41230e-1452-4d25-bf64-a317d755227c
begin
	@time obsval, obslon, obslat, obsdepth, obstime, obsid =
	    NCODV.load(Float64, datafile, "Water body salinity");
	
	f1 = GeoMakie.Figure()
	ax1 = GeoAxis(f1[1, 1], dest = "+proj=merc", title = "Observations")
	GeoMakie.scatter!(ax1, obslon, obslat; markersize = 2, color = :black)
	f1
end

# ╔═╡ 6c0367fe-028c-445d-bf84-af58bdb5225d
md"""
### Check the extremal values of the observations
"""

# ╔═╡ 9208c12d-0c3d-404e-b439-c87ae9420bc4
checkobs((obslon, obslat, obsdepth, obstime), obsval, obsid)

# ╔═╡ 74ec774c-f4ad-42f3-84ea-e3897ef20d96
md"""
## 🌏 Extract the bathymetry
It is used to delimit the domain where the interpolation is performed.
 
### Choice of bathymetry
Modify bathname according to the resolution required.
"""

# ╔═╡ 2ecb1ee7-1fec-40f9-bdfe-6f854b651732
begin
	bathname = gebco08file
	download_check(bathname, gebco08fileURL)
	
	@time bx, by, b = load_bath(bathname, true, lonr, latr);
	
	plot_bathy(bx, by, b, xticks = 10.0:2.0:20.0, yticks = 39.0:2:48.0)
end

# ╔═╡ f837f963-a4f2-48d5-b167-34fcef7ec33a
md"""
### Create mask
- `False` for sea points
- `True` for land points
"""

# ╔═╡ cb4592a2-c372-45c6-8146-91b9c9f726d6
begin
	_, _, mask = load_mask(bathname, true, lonr, latr, depthr)
	
	plot_mask(bx, by, mask[:, :, 1], xticks = 10.0:2.0:20.0, yticks = 39.0:2:48.0)
end

# ╔═╡ 384b3601-056b-4213-a0d9-581659c18eed
md"""
### ✏️ Edit the mask
As an example we will remove the Tyrrhenian Sea from the domain.
"""

# ╔═╡ 7094f94b-fec9-40e7-aaa5-198067036eda
begin
	grid_bx = [i for i in bx, j in by];
	grid_by = [j for i in bx, j in by];
	
	mask_edit = copy(mask);
	sel_mask1 = (grid_by .<= 42.6) .& (grid_bx .<= 14.0);
	sel_mask2 = (grid_by .<= 41.2) .& (grid_bx .<= 16.2);
	mask_edit = mask_edit .* .!sel_mask1 .* .!sel_mask2;
	@show size(mask_edit)
end

# ╔═╡ 9c9899eb-0392-4b41-bf8f-ffcd9d26348a
md"""
The edited mask now looks like this:
"""

# ╔═╡ a20ea670-e39a-4216-8595-d2e843c9d0ea
plot_mask(bx, by, mask_edit[:, :, 1], xticks = 10.0:2.0:20.0, yticks = 39.0:2:48.0)

# ╔═╡ 88a66795-e486-4770-9c02-f6bf91769913
md"""
## Extract data from other sources

As an illustration we use the [World Ocean Database](https://www.ncei.noaa.gov/products/world-ocean-database), among other possibilities.

### Configuration

For this example it is necessary to use your email address:
"""

# ╔═╡ c334599b-15fe-4f80-b6b8-5af932fa48ba
begin 
	if isfile("email.txt")
	    email = strip(read("email.txt", String))
	    print("getting email address from email.txt")
	end
	# Or create the variable here:
	email = "...."
	
	woddatadir = joinpath(datadir(), "AdriaticTest/")
	mkpath(woddatadir);
	@info(woddatadir);
end

# ╔═╡ 88644eb0-b0c9-45a5-831b-08a9e80c6860
md"""
!!! note
     Uncomment the next cell if you have to download the data for your region.  Otherwise you can download an archive already containing a sample of observations from the World Ocean Atlas.
"""

# ╔═╡ 4ef702f9-4a00-46b6-8190-50b60e075c79
# WorldOceanDatabase.download(lonr,latr,timerange,varname,email,woddatadir);

#   The following will download an example file and extract its content in
#   Diva-Workshops/notebooks/3-Analysis/Adriatic. If this fails, the data has to
#   be downloaded manuary (in zip format or tar.gz format)
# 
#   Make sure to have a file at the path
#   Diva-Workshops/notebooks/3-Analysis/Adriatic/WOD/GLD/ocldb1560025519.12915.GLD.nc.

# ╔═╡ feb4fc78-b96e-4476-a46a-a604e91b0aae
begin 
	download_check(WODadriaticfile, WODadriaticfileURL)
	extractcommand = `tar -C $(woddatadir) -xzf $(WODadriaticfile)`
	run(extractcommand);

		if isfile(joinpath(woddatadir, "WOD-Adriatic/WOD/GLD", "ocldb1560025519.12915.GLD.nc"))
	    @info("Files have been sucessfully decompressed")
	else
	    @warn("Please decompress the file manually")
	end
end

# ╔═╡ 9b34d0e9-2723-4312-8033-7f473a444634
md"""
### ⌛⌛ Read the data. 
This can also take up to a few minutes, depending on the
size of the domain.
"""

# ╔═╡ dc982b14-45ce-4d65-8902-38b21b54dbe4
md"""
!!! warning 
    The WOD observations IDs have to be modified in order to be ingested by the XML generation: we haver to append the EDMO code of the U.S. NODC, which is 1977.
"""

# ╔═╡ 3896b207-4adb-4100-8082-110be890a4f9
begin
	@time obsvalwod,obslonwod,obslatwod,obsdepthwod,obstimewod,obsidwod = 
	WorldOceanDatabase.load(Float64, joinpath(woddatadir, "WOD"), "Temperature" ,prefixid = "1977-");
	@info("Found $(length(obslatwod)) observations in WOD")
end

# ╔═╡ 95ef106f-2978-4c15-9e5d-b4d7f6993136
md"""
###   Remove the data outside Adriatic (similar to mask editing)
"""

# ╔═╡ 6a8cc095-1db8-421f-b36f-76095e78537e
begin
	sel_data1 = (obslatwod .<= 42.6) .& (obslonwod .<= 14.);
	sel_data2 = (obslatwod .<= 41.2) .& (obslonwod .<= 16.2);
	ndataremove = sum((sel_data1) .| (sel_data2))
	sel_data = .~((sel_data1) .| (sel_data2));
	
	obslatwod_sel = obslatwod[sel_data];
	obslonwod_sel = obslonwod[sel_data];	  
						  
	obsdepthwod_sel = obsdepthwod[sel_data];
	obstimewod_sel = obstimewod[sel_data];
	obsvalwod_sel = obsvalwod[sel_data];
	obsidwod_sel = obsidwod[sel_data];
end

# ╔═╡ 36d68bbe-ecae-4625-b565-aa9814bffa15
md"""
### Plot of the 2 datasets
"""

# ╔═╡ bb8b4704-2c04-44d4-8a24-2fdd274bca5c
begin
	@info("Number of removed WOD data: $ndataremove");
	obsidwod[1:5]
	
	f2 = Figure()
	ax2 = GeoAxis(f2[1,1], dest = "+proj=merc", title="Observations")
	heatmap!(ax2, collect(lonr), collect(latr), mask_edit[:,:,1], colormap=Reverse(:binary))
	scatter!(ax2, obslon, obslat; markersize=2, color=:blue, label="SeaDataNet")
	scatter!(ax2, obslonwod_sel, obslatwod_sel; markersize=2, color=:green, label="World Ocean Database")
	Legend(f2[1, 2], ax2, "Datasets")
	f2
end

# ╔═╡ b9db095e-3426-445a-9685-fd5fdaf07391
md"""
### Extract from another source (optional)

Add in the cell below the code to read data from another file.
"""

# ╔═╡ 037e9dfa-7518-4774-824f-b5aa57a47771


# ╔═╡ 307299f2-3ef4-41b5-91e7-a341b895434f
md"""
##  Remove duplicates

⌛ The idea here to remove the duplicates coming from the combination of two
datasets: SeaDataNet and World Ocean Database. If one has to perform a
duplicate detection on a unique dataset (for instance SeaDataNet only), a
similar procedure can be applied, as explained below.

### Criteria
Some values have to be set for the tolerance concerning the positions, times
and values of the observations:
- Horizontal distance: 0.05 degree (about 5 km)
- Vertical separation: 0.05 m depth
- Time separation: 1 minute.
- Salinity difference: 0.1 psu.
"""

# ╔═╡ e7be077a-a392-4633-9695-3eac8415c3c3
@time dupl = DIVAnd.Quadtrees.checkduplicates(
    (obslon,obslat,obsdepth,obstime), obsval, 
    (obslonwod_sel, obslatwod_sel, obsdepthwod_sel, obstimewod_sel), obsvalwod_sel,
    (0.05, 0.05, 0.05, 1/(24*60)), 0.1);

# ╔═╡ db532ce4-d4ba-44ee-9037-d00fe0116df5
md"""
!!! note
      The values in the previous cell were set to ensure some duplicates are identified. In a realistic application, they have to be adapted according to the datasets, the variables etc. Once the parameters have been set, the following command allows one to identify the _potential_ duplicates:
"""

# ╔═╡ c4fc3808-a19d-45c5-8603-242050c82d40
md"""
## Duplicate from only one data source
If we need to identify duplicates coming only from the SeaDataNet dataset,
the following command can be executed:
"""

# ╔═╡ f088b184-ff5f-486b-9c2c-4a83144de059
begin
	@time duplSDN = DIVAnd.Quadtrees.checkduplicates(
	    (obslon, obslat, obsdepth, obstime),
	    obsval,
	    (0.01, 0.01, 0.01, 1 / (24 * 60)),
	    0.01,
	);
end

# ╔═╡ 2289bdcb-7638-40d8-b038-90e569d012f4
md"""
### Find the indices of the possible duplicates:
"""

# ╔═╡ 619c1f4a-d077-4dee-b518-a2d4ace663e2
begin
	index = findall(.!isempty.(dupl));
	ndupl = length(index);
	pcdupl = round(ndupl / length(obslon) * 100; digits=2);
	@info("Number of possible duplicates: $ndupl")
	@info("Percentage of duplicates: $pcdupl%")
end

# ╔═╡ 030576a1-1cf7-4173-880e-d1b36fa7bb33
md"""
If you decide to combine the 2 (or more) datasets:
"""

# ╔═╡ a84d6b23-91f7-4206-b98c-21a0b2f24628
begin
	newpoints = isempty.(dupl);
	@info("Number of new points: $(sum(newpoints)))")
	
	obslon_merged = [obslon; obslonwod_sel[newpoints]];
	obslat_merged = [obslat; obslatwod_sel[newpoints]];
	obsdepth_merged = [obsdepth; obsdepthwod_sel[newpoints]];
	obstime_merged = [obstime; obstimewod_sel[newpoints]];
	obsval_merged = [obsval; obsvalwod_sel[newpoints]];
	obsid_merged = [obsid; obsidwod_sel[newpoints]];
end

# ╔═╡ 9c0e1f07-b185-4f22-9e73-ad29e1fa71b9
md"""
### Create a plot
To show the additional data points
"""

# ╔═╡ 87a2ca37-5b49-4006-abbd-6d7f30faaaac
begin
	f = GeoMakie.Figure()
	ax = GeoAxis(f[1,1], dest = "+proj=merc", title="Observations")
	GeoMakie.heatmap!(ax, collect(lonr), collect(latr), mask_edit[:,:,1], colormap=Reverse(:binary))
	GeoMakie.scatter!(ax, obslon, obslat; markersize=2, color=:blue, label="SeaDataNet")
	GeoMakie.scatter!(ax, obslonwod_sel[newpoints], obslatwod_sel[newpoints]; markersize=2, color=:green, 
	    label="Additional data\nfrom World Ocean Database")
	GeoMakie.Legend(f[1, 2], ax, "Datasets")
	f
end

# ╔═╡ 83f759da-8023-4143-9697-5d2e20165855
md"""
### Quality control
We check the salinity value. Adapt the criteria to your region and variable.
"""

# ╔═╡ 2cc9548e-548b-4c02-a7a7-602a0f64675a
begin
	sel = (obsval_merged .<= 40) .& (obsval_merged .>= 25);
	
	obsval_sel = obsval_merged[sel]
	obslon_sel = obslon_merged[sel]
	obslat_sel = obslat_merged[sel]
	obsdepth_sel = obsdepth_merged[sel]
	obstime_sel = obstime_merged[sel]
	obsid_sel = obsid_merged[sel]
end

# ╔═╡ 3e4cde73-bc96-4efa-b92e-b77dab0ec289
md"""
## Analysis parameters
### Modify data weight
The new weights are computed in order to take into account the distance
between points. 

!!! info 
    If the dataset
    is large, this can take a few minutes. 

The maximal and mean values provide an indication of the spatial proximity
between the data. If you apply this technique, you need to adapt epsilon2 as
`epsilon2 = epsilon2 * rdiag`.
"""

# ╔═╡ 9e1b95cd-fe58-4f8f-9d5d-712d5506ec1d
begin
	@time rdiag = 1.0 ./ DIVAnd.weight_RtimesOne((obslon_sel, obslat_sel), (0.03, 0.03));
	@show
end

# ╔═╡ 0f7e15a1-32c4-45e9-9597-d4f419e35045
md"""
### Set correlation lengths and noise-to-signal ratio

We will use the function `diva3d` for the calculations. With this function,
the correlation length has to be defined in meters, not in degrees.
"""

# ╔═╡ e991be2e-57cf-4046-973d-04bf9e149748
begin
	sz = (length(lonr), length(latr), length(depthr));
	lenx = fill(100_000.0, sz)   # 100 km
	leny = fill(100_000.0, sz)   # 100 km
	lenz = fill(25.0, sz);      # 25 m 
	len = (lenx, leny, lenz);
	epsilon2 = 0.1;
	#epsilon2 = epsilon2 * rdiag;
end

# ╔═╡ 5bb55687-5c76-438c-808e-8434a730b4af
md"""
Set the output file name
"""

# ╔═╡ 6a155fc1-b19e-485e-a3e9-345a1e7d77e9
filename = joinpath(outputdir, "Water_body_$(replace(varname," "=>"_"))_Adriatic.4Danl.nc")


# ╔═╡ 019efea3-5307-4f5a-985c-63f66dfa07f2
md"""
### Metadata and attributes
Edit the different fields according to the project, the authors etc. This is
used for the netCDF file but also for the XML needed for the Sextant catalog.
"""

# ╔═╡ ff21999a-5087-43d7-8c0f-189891cebad0
metadata = OrderedDict(
    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-chemistry, ...)
    "project" => "SeaDataCloud",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "institution_urn" => "SDN:EDMO::1579",

    # Production group
    #"production" => "Diva group",

    # Name and emails from authors
    "Author_e-mail" =>
        ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

    # Source of the observation
    "source" => "observational data from SeaDataNet and World Ocean Atlas",

    # Additional comment
    "comment" => "Duplicate removal applied to the merged dataset",

    # SeaDataNet Vocabulary P35 URN
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p35
    # example: SDN:P35::WATERTEMP
    "parameter_keyword_urn" => "SDN:P35::EPC00001",

    # List of SeaDataNet Parameter Discovery Vocabulary P02 URNs
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p02
    # example: ["SDN:P02::TEMP"]
    "search_keywords_urn" => ["SDN:P02::PSAL"],

    # List of SeaDataNet Vocabulary C19 area URNs
    # SeaVoX salt and fresh water body gazetteer (C19)
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=C19
    # example: ["SDN:C19::3_1"]
    "area_keywords_urn" => ["SDN:C19::3_3"],
    "product_version" => "1.0",
    "product_code" => "something-to-decide",

    # bathymetry source acknowledgement
    # see, e.g.
    # * EMODnet Bathymetry Consortium (2016): EMODnet Digital Bathymetry (DTM).
    # https://doi.org/10.12770/c7b53704-999d-4721-b1a3-04ec60c87238
    # 
    # taken from
    # http://www.emodnet-bathymetry.eu/data-products/acknowledgement-in-publications
    #
    # * The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003
    #
    # taken from
    # https://www.bodc.ac.uk/projects/data_management/international/gebco/gebco_digital_atlas/copyright_and_attribution/

    "bathymetry_source" => "The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003",

    # NetCDF CF standard name
    # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
    # example "standard_name" = "sea_water_temperature",
    "netcdf_standard_name" => "sea_water_salinity",
    "netcdf_long_name" => "sea water salinity",
    "netcdf_units" => "1e-3",

    # Abstract for the product
    "abstract" => "...",

    # This option provides a place to acknowledge various types of support for the
    # project that produced the data
    "acknowledgement" => "...",
    "documentation" => "https://doi.org/doi_of_doc",

    # Digital Object Identifier of the data product
    "doi" => "...",
);


# ╔═╡ 8e23ac6b-37ae-4dd7-ba5b-8c9fca8ddbf5
md"""
#### Add the SeaDataNet global attributes
"""

# ╔═╡ 4a391071-c222-4afb-9a70-0bf69d6aa484
ncglobalattrib, ncvarattrib = SDNMetadata(metadata, filename, varname, lonr, latr)

# ╔═╡ 80ce6471-57f0-40a9-9d40-d441d6f591da
md"""
## Analysis
Remove the result file before running the analysis, otherwise you'll get the   message 
`NCDatasets.NetCDFError(13, "Permission denied")`
"""

# ╔═╡ 9286eb7f-9c04-4a7e-bcc7-c554f2e32efe
if isfile(filename)
    rm(filename) # delete the previous analysis
    @info "Removing file $filename"
end

# ╔═╡ c487f35f-856d-40a8-ae0d-916868354085
md"""
### Plotting function
Define a plotting function that will be applied for each time index and
depth level.      
All the figures will be saved in a selected directory.
"""

# ╔═╡ dc0e8f83-09e7-4213-a2dc-e9d9ffe44776
begin 
	figdir = "../figures/Adriatic/"
	isdir(figdir) ? @info("Figure directory already exists") : mkdir(figdir)
end

# ╔═╡ 416229ec-1c47-4a9c-9e35-fddac62fd8a9
function plotres(timeindex, sel, fit, erri; vmin = 33, vmax = 40)
    tmp = copy(fit)
    nx, ny, nz = size(tmp)

    for i = 1:nz
        fig = Figure()

        # plot the data
        ga = GeoAxis(
            fig[1, 1];
            dest = "+proj=merc",
            title = "Depth: $(depthr[i]) \n Time index: $(timeindex)",
        )
        heatmap!(ga, lonr, latr, mask[:, :, i], colormap = Reverse(:binary))
        hm = heatmap!(
            ga,
            lonr,
            latr,
            tmp[:, :, i],
            interpolate = false,
            colorrange = [vmin, vmax],
        )

        xlims!(ga, (lonr[1], lonr[end]))
        ylims!(ga, (latr[1], latr[end]))
        Colorbar(fig[2, 1], hm, vertical = false)

        # display(fig)
        figname = joinpath(
            figdir,
            varname * "_" * lpad(i, 2, '0') * "_" * lpad(timeindex, 3, '0') * ".png",
        )
        save(figname, fig)
    end
end

# ╔═╡ 888481aa-3a21-43fd-ac7a-ccaed2c4ee68
md"""
### Create the gridded fields using `diva3d`

Here only the noise-to-signal ratio is estimated. Set `fitcorrlen` to `true` to
also optimise the correlation length.
"""

# ╔═╡ d9397dbb-39f3-4e52-8071-53d9fa696f56
begin
	@time dbinfo = diva3d(
	    (lonr, latr, depthr, TS),
	    (obslon, obslat, obsdepth, obstime),
	    obsval,
	    len,
	    epsilon2,
	    filename,
	    varname,
	    bathname = bathname,
	    plotres = plotres,
	    mask = mask_edit,
	    fitcorrlen = false,
	    niter_e = 2,
	    ncvarattrib = ncvarattrib,
	    ncglobalattrib = ncglobalattrib,
	    surfextend = true,
	);
end

# ╔═╡ f1c970d7-6dbb-4c0c-a19f-54e5a084de68
md"""
### Save the observation metadata
"""

# ╔═╡ 5ee99a09-7ef2-4168-8247-46d9ca01d8f4
begin
	DIVAnd.saveobs(
	    filename,
	    "salinity obs",
	    obsval,
	    (obslon, obslat, obsdepth, obstime),
	    obsid,
	    used = dbinfo[:used],
	)
end

# ╔═╡ 81548ef0-b785-4fc1-8fcd-b470202dd1e9
md"""
### XML metadata

or DIVAnd analysis using SeaDataCloud/EMODnet-Chemistry data, one can
create a XML description for the product for Sextant

Name of the project:
- "SeaDataCloud" or
- "EMODNET-chemistry"
"""

# ╔═╡ cd18c65c-ba69-4d42-9ad0-81ecb232fa77
begin

	project = "SeaDataCloud";
	#project = "EMODNET-chemistry"
	
	#   Download CDI list
	
	cdilist = joinpath(datadir(), "CDI-list-export.zip")
	
	if !isfile(cdilist)
	    Downloads.download("http://emodnet-chemistry.maris2.nl/download/export.zip", cdilist)
	end
	
	#   If ignore_errors is false (default), then a missing CDI will stop the
	#   creatation of the XML metadata.
	
	ignore_errors = true
	
	# File name based on the variable (but all spaces are replaced by underscores)
	xmlfilename = joinpath(outputdir, "Water_body_$(replace(varname," "=>"_")).4Danl.xml")
end

# ╔═╡ 1332d3e2-4926-4779-be5b-147b5539a8eb
#   Generate a XML file for Sextant catalog
#   =======================================
# 
#   Uncomment the following line of you are using SeaDataCloud or
#   EMODnet-Chemistry data.
# 
#   <div class="alert alert-block alert-warning"> ⚠️ This step requires an
#   internet connection. If the code is running on a machine without a
#   connection, then the global and variable attributes have to be prepared
#   before the main run and saved to files. </div>

# divadoxml(filename,varname,project,cdilist,xmlfilename, ignore_errors = ignore_errors)

# ╔═╡ Cell order:
# ╟─b2386b36-3f8f-4a1a-b08f-9f654d2059af
# ╠═6b965927-0eb7-4db1-adef-f32d9fca9ca0
# ╟─55f04355-fabf-4ace-bba5-048b07c2abf2
# ╠═98df5c0f-3810-41ed-8b4a-ec087bd03370
# ╟─bde7863c-fad3-4416-92df-aea60e50e6e5
# ╠═f0982375-9b50-452d-9c2d-c530c2ad7aa4
# ╟─bde1f534-318b-4709-b817-9dc4dfe2bd4c
# ╠═c7e43d03-6b21-4df8-9008-1f32a4bb37c9
# ╟─0434458f-ce8c-4814-a8aa-de6fc35c21e0
# ╠═3d41230e-1452-4d25-bf64-a317d755227c
# ╟─6c0367fe-028c-445d-bf84-af58bdb5225d
# ╠═9208c12d-0c3d-404e-b439-c87ae9420bc4
# ╟─74ec774c-f4ad-42f3-84ea-e3897ef20d96
# ╠═2ecb1ee7-1fec-40f9-bdfe-6f854b651732
# ╟─f837f963-a4f2-48d5-b167-34fcef7ec33a
# ╠═cb4592a2-c372-45c6-8146-91b9c9f726d6
# ╟─384b3601-056b-4213-a0d9-581659c18eed
# ╠═7094f94b-fec9-40e7-aaa5-198067036eda
# ╟─9c9899eb-0392-4b41-bf8f-ffcd9d26348a
# ╠═a20ea670-e39a-4216-8595-d2e843c9d0ea
# ╟─88a66795-e486-4770-9c02-f6bf91769913
# ╠═c334599b-15fe-4f80-b6b8-5af932fa48ba
# ╟─88644eb0-b0c9-45a5-831b-08a9e80c6860
# ╠═4ef702f9-4a00-46b6-8190-50b60e075c79
# ╠═feb4fc78-b96e-4476-a46a-a604e91b0aae
# ╟─9b34d0e9-2723-4312-8033-7f473a444634
# ╟─dc982b14-45ce-4d65-8902-38b21b54dbe4
# ╠═3896b207-4adb-4100-8082-110be890a4f9
# ╟─95ef106f-2978-4c15-9e5d-b4d7f6993136
# ╠═6a8cc095-1db8-421f-b36f-76095e78537e
# ╟─36d68bbe-ecae-4625-b565-aa9814bffa15
# ╠═bb8b4704-2c04-44d4-8a24-2fdd274bca5c
# ╟─b9db095e-3426-445a-9685-fd5fdaf07391
# ╠═037e9dfa-7518-4774-824f-b5aa57a47771
# ╟─307299f2-3ef4-41b5-91e7-a341b895434f
# ╠═e7be077a-a392-4633-9695-3eac8415c3c3
# ╟─db532ce4-d4ba-44ee-9037-d00fe0116df5
# ╟─c4fc3808-a19d-45c5-8603-242050c82d40
# ╠═f088b184-ff5f-486b-9c2c-4a83144de059
# ╟─2289bdcb-7638-40d8-b038-90e569d012f4
# ╠═619c1f4a-d077-4dee-b518-a2d4ace663e2
# ╟─030576a1-1cf7-4173-880e-d1b36fa7bb33
# ╠═a84d6b23-91f7-4206-b98c-21a0b2f24628
# ╟─9c0e1f07-b185-4f22-9e73-ad29e1fa71b9
# ╠═87a2ca37-5b49-4006-abbd-6d7f30faaaac
# ╟─83f759da-8023-4143-9697-5d2e20165855
# ╠═2cc9548e-548b-4c02-a7a7-602a0f64675a
# ╟─3e4cde73-bc96-4efa-b92e-b77dab0ec289
# ╠═9e1b95cd-fe58-4f8f-9d5d-712d5506ec1d
# ╟─0f7e15a1-32c4-45e9-9597-d4f419e35045
# ╠═e991be2e-57cf-4046-973d-04bf9e149748
# ╟─5bb55687-5c76-438c-808e-8434a730b4af
# ╠═6a155fc1-b19e-485e-a3e9-345a1e7d77e9
# ╟─019efea3-5307-4f5a-985c-63f66dfa07f2
# ╠═ff21999a-5087-43d7-8c0f-189891cebad0
# ╟─8e23ac6b-37ae-4dd7-ba5b-8c9fca8ddbf5
# ╠═4a391071-c222-4afb-9a70-0bf69d6aa484
# ╟─80ce6471-57f0-40a9-9d40-d441d6f591da
# ╠═9286eb7f-9c04-4a7e-bcc7-c554f2e32efe
# ╟─c487f35f-856d-40a8-ae0d-916868354085
# ╠═dc0e8f83-09e7-4213-a2dc-e9d9ffe44776
# ╠═416229ec-1c47-4a9c-9e35-fddac62fd8a9
# ╟─888481aa-3a21-43fd-ac7a-ccaed2c4ee68
# ╠═d9397dbb-39f3-4e52-8071-53d9fa696f56
# ╟─f1c970d7-6dbb-4c0c-a19f-54e5a084de68
# ╠═5ee99a09-7ef2-4168-8247-46d9ca01d8f4
# ╟─81548ef0-b785-4fc1-8fcd-b470202dd1e9
# ╠═cd18c65c-ba69-4d42-9ad0-81ecb232fa77
# ╟─1332d3e2-4926-4779-be5b-147b5539a8eb

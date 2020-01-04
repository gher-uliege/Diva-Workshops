
using DIVAnd
using PyPlot
using NCDatasets
using PhysOcean
using DataStructures
using PyPlot
if VERSION >= v"0.7.0-beta.0"
    using Dates
    using Statistics
    using Random
    using Printf
else
    using Compat: @info, @warn, @debug
end
using Compat

datadir = "SeaDataCloud"
datafile = joinpath(datadir, "data_from_SDN_2015-09_TS_Atlantic_QC_done_v2.nc")
smalldatanc = joinpath(datadir, "smallData.nc")
isfile(datafile)

varname = "Salinity"

if !isfile(joinpath(datadir,"obs.nc"))
    @time obsval, obslon, obslat, obsdepth, obstime, obsid = NCODV.load(
        Float64,
        datafile, "Water body salinity");

    DIVAnd.saveobs(joinpath(datadir,"obs.nc"),varname,obsval,
                   (obslon, obslat, obsdepth, obstime),obsid)
else
    obsval,obslon, obslat, obsdepth, obstime,obsid = DIVAnd.loadobs(Float64,joinpath(datadir,"obs.nc"),varname)
end


@show extrema(obslon);
@show extrema(obslat);
@show extrema(obstime);

Δx, Δy = 2.0, 2.0
lonr = -100.0:Δx:0.0
latr = 9.0:Δy:71.0
timerange = [Date(1900,1,1),Date(2015,12,31)];

depthr = [0.,5., 10., 15., 20., 25., 30., 40., 50., 66, 
    75, 85, 100, 112, 125, 135, 150, 175, 200, 225, 250, 
    275, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 
    800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 
    1300, 1350, 1400, 1450, 1500, 1600, 1750, 1850, 2000];
#depthr = [0.,20.,50.];

# year and month-list for background analysis
yearlist = [1900:1989,1990:2017];
monthlist = [[1,2,3],[4,5,6],[7,8,9],[10,11,12]];  # Seasonal climatology
TSbackground = DIVAnd.TimeSelectorYearListMonthList(yearlist,monthlist);


obslon[obslon.>180.] = obslon[obslon.>180.] .- 360.;
@show extrema(obslon);

coords = [(x,y) for (x,y) in zip(obslon, obslat)];
coords_u = unique(coords);
@info "Total number of coordinates: $(length(coords))"
@info "Number of unique coordinates (profiles): $(length(coords_u))"

obslon_u = [x[1] for x in coords_u];
obslat_u = [x[2] for x in coords_u];

figure("Atlantic-Data")
ax = subplot(1,1,1)
plot(obslon_u, obslat_u, "ko", markersize=.2)
aspect_ratio = 1/cos(mean(latr) * pi/180)
ax[:tick_params]("both",labelsize=6)
ax[:set_aspect](aspect_ratio)

checkobs((obslon,obslat,obsdepth,obstime),obsval,obsid)

bathname = joinpath(datadir, "gebco_30sec_16.nc")
# https://dox.ulg.ac.be/index.php/s/RSwm4HPHImdZoQP/download  gebco_30sec_4.nc
# https://dox.ulg.ac.be/index.php/s/wS6Y8P8NhIF60eG/download  gebco_30sec_8.nc
# https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download  gebco_30sec_16.nc

if !isfile(bathname)
    download("https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download",bathname)
else
    @info "Bathymetry file already downloaded"
end

@time bx,by,b = load_bath(bathname,true,lonr,latr);

figure("Atlantic-Bathymetry")
ax = gca()
pcolor(bx,by,permutedims(b, [2,1]));
colorbar(orientation="vertical", shrink=0.8)[:ax][:tick_params](labelsize=8)
contour(bx,by,permutedims(b, [2,1]), [0, 0.1], colors="k", linewidths=.5)
ax[:set_aspect](aspect_ratio)
ax[:tick_params]("both",labelsize=6)

# surface mask
surfwater = b .>= depthr[1]
ax = gca()
figure("Atlantic-water")
ax[:set_aspect](aspect_ratio)
ax[:tick_params]("both",labelsize=6)
pcolor(bx,by,Float64.(surfwater'))


label = DIVAnd.floodfill(surfwater)
surfmask = label .== 1 # largest area has the label 1

figure("Atlantic-Mask")
ax = gca()
ax[:set_aspect](aspect_ratio)
ax[:tick_params]("both",labelsize=6)
pcolor(bx,by,Float64.(surfmask'))

mask = falses(size(b,1),size(b,2),length(depthr))
for k = 1:length(depthr)
    for j = 1:size(b,2)
        for i = 1:size(b,1)
            mask[i,j,k] = (b[i,j] >= depthr[k]) && surfmask[i,j]
        end
    end
end
@show size(mask)

#=
email = "a.barth@uliege.be"
woddatadir = joinpath(datadir,"WOD")

if !isfile(joinpath(datadir,"obs-wod-combined.nc"))
    mkpath(woddatadir);

    WorldOceanDatabase.download(lonr,latr,timerange,varname,email,woddatadir);

    @time obsvalwod,obslonwod,obslatwod,obsdepthwod,obstimewod,obsidwod =
        WorldOceanDatabase.load(Float64,woddatadir,varname);

    # 1977 is the EMDO code of the NOAA/NODC

    obsidwod = map(wodid -> "1977-" * wodid,obsidwod)

    @time dupl = DIVAnd.Quadtrees.checkduplicates(
        (obslon,obslat,obsdepth,obstime), obsval,
        (obslonwod,obslatwod, obsdepthwod, obstimewod), obsvalwod,
        (0.01,0.01,0.01,1/(24*60)),0.01);

    index = findall.(.!isempty.(dupl));
    ndupl = length(index);
    pcdupl = round(ndupl / length(obslon) * 100; digits=2);
    @info "Number of possible duplicates: $ndupl"
    @info "Percentage of duplicates: $pcdupl%"

    newpoints = isempty.(dupl);
    @info "Number of new points: " * string(sum(newpoints))

    obslon = [obslon; obslonwod[newpoints]];
    obslat = [obslat; obslatwod[newpoints]];
    obsdepth = [obsdepth; obsdepthwod[newpoints]];
    obstime = [obstime; obstimewod[newpoints]];
    obsval = [obsval; obsvalwod[newpoints]];
    obsid = [obsid; obsidwod[newpoints]];

    figure("Additional-Data")
    ax = subplot(1,1,1)
    ax[:tick_params]("both",labelsize=6)
    ylim(39.0, 46.0);
    xlim(11.5, 20.0);
    contourf(bx, by, permutedims(Float64.(mask_edit[:,:,1]),[2,1]),
        levels=[-1e5,0],cmap="binary");
    plot(obslon, obslat, "bo", markersize=.2, label="SeaDataNet")
    plot(obslonwod[newpoints], obslatwod[newpoints], "go",
        markersize=.2, label="Additional data\nfrom World Ocean Database")
    legend(loc=3, fontsize=4)
    ax[:set_aspect](aspect_ratio)

    DIVAnd.saveobs(joinpath(datadir,"obs-wod-combined.nc"),varname,obsval,
                   (obslon, obslat, obsdepth, obstime),obsid)
else
    obsval,obslon, obslat, obsdepth, obstime,obsid = DIVAnd.loadobs(Float64,joinpath(datadir,"obs-wod-combined.nc"),varname)
end
=#

sel = (obsval .<= 40) .& (obsval .>= 25);

obsval = obsval[sel]
obslon = obslon[sel]
obslat = obslat[sel]
obsdepth = obsdepth[sel]
obstime = obstime[sel]
obsid = obsid[sel];

#@time rdiag=1.0./DIVAnd.weight_RtimesOne((obslon,obslat),(0.03,0.03));
#@show maximum(rdiag),mean(rdiag)

sz = (length(lonr),length(latr),length(depthr));
lenx = fill(200_000.,sz)   # 200 km
leny = fill(200_000.,sz)   # 200 km
lenz = [min(max(30.,depthr[k]/150),300.) for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]]
lenbackground = (lenx, leny, lenz);
# determined by DIVAnd
len = (ones(sz),ones(sz),ones(sz))
epsilon2 = 0.1;
#epsilon2 = epsilon2 * rdiag;



filenamebackground = "Water_body_$(replace(varname," "=>"_"))_Atlantic_background.4Danl.nc"
filename = "Water_body_$(replace(varname," "=>"_"))_Atlantic.4Danl.nc"

metadata = OrderedDict(
    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-chemistry, ...)
    "project" => "SeaDataCloud",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "institution_urn" => "SDN:EDMO::1579",

    # Production group
    #"production" => "Diva group",

    # Name and emails from authors
    "Author_e-mail" => ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

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
    "doi" => "...");

ncglobalattrib,ncvarattrib = SDNMetadata(metadata,filename,varname,lonr,latr);

if isfile(filenamebackground)
    rm(filenamebackground) # delete the previous analysis
    @info "Removing file $filenamebackground"
end

figdir = "./Atlantic/figures/"
if !isdir(figdir)
    mkpath(figdir);
    @info "Creating directory $(figdir)"
end
solver = :direct

function plotres(timeindex,sel,fit,erri)
    tmp = copy(fit)
    nx,ny,nz = size(tmp)
    for i in 1:nz
        figure("Atlantic analysis")
        ax = subplot(1,1,1)
        ax[:tick_params]("both",labelsize=6)
        ylim(minimum(latr) - Δy, maximum(latr) + Δy);
        xlim(minimum(lonr) - Δx, maximum(lonr) + Δx);
        title("Depth: $(depthr[i]) \n Time index: $(timeindex)", fontsize=6)
        pcolor(lonr.-Δx/2.,latr.-Δy/2, permutedims(tmp[:,:,i], [2,1]);
               vmin = 33, vmax = 40)
        colorbar(extend="both", orientation="vertical", shrink=0.8)[:ax][:tick_params](labelsize=8)

        contourf(bx,by,permutedims(b,[2,1]), levels = [-1e5,0],colors = [[.5,.5,.5]])
        ax[:set_aspect](aspect_ratio)
        
        figname = varname * @sprintf("_%02d",i) * @sprintf("_%03d.png",timeindex)
        PyPlot.savefig(joinpath(figdir, figname), dpi=300, bbox_inches="tight");
        PyPlot.close_figs()
    end
end

# background analysis
dbinfo = @time diva3d((lonr,latr,depthr,TSbackground),
                      (obslon,obslat,obsdepth,obstime), obsval,
                      lenbackground, epsilon2,
                      filenamebackground,varname,
                      bathname=bathname,
                      mask = mask,
                      fitcorrlen = false,
                      ncvarattrib = ncvarattrib,
                      ncglobalattrib = ncglobalattrib,
                      solver = solver,
                      MEMTOFIT = 120,
                      );


yearlist = [1970:1979,1980:1989,1990:1999,2000:2009];
monthlist = [[1,2,3],[4,5,6],[7,8,9],[10,11,12]];  # Seasonal climatology
TS = DIVAnd.TimeSelectorYearListMonthList(yearlist,monthlist);

if isfile(filename)
    rm(filename) # delete the previous analysis
    @info "Removing file $filename"
end

# analysis using background field

dbinfo = @time diva3d((lonr,latr,depthr,TS),
                      (obslon,obslat,obsdepth,obstime), obsval,
                      len, epsilon2,
                      filename,varname,
                      bathname=bathname,
                      #    plotres = plotres,
                      mask = mask,
                      fitcorrlen = true,
                      fithorz_param = Dict(:limitfun => (len,z) -> min(max(len,50_000),200_000)),
                      fitvert_param = Dict(:limitfun => (len,z) -> min(max(len,20),200)),
                      niter_e = 2,
                      ncvarattrib = ncvarattrib,
                      ncglobalattrib = ncglobalattrib,
                      background = DIVAnd.backgroundfile(filenamebackground,varname,TSbackground),
                      solver = solver,
                      MEMTOFIT = 120,
);

DIVAnd.saveobs(filename,(obslon,obslat,obsdepth,obstime),obsid);

project = "SeaDataCloud";

cdilist = joinpath(datadir, "CDI-list-export.zip")

if !isfile(cdilist)
   download("http://emodnet-chemistry.maris2.nl/download/export.zip",cdilist)
end

ignore_errors = true

# File name based on the variable (but all spaces are replaced by _)
xmlfilename = joinpath(datadir,"Water_body_$(replace(varname," "=>"_")).4Danl.xml")

# generate a XML file for Sextant (only for )
divadoxml(filename,varname,project,cdilist,xmlfilename,
          ignore_errors = ignore_errors)

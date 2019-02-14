
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

datadir = "/home/ctroupin/Data/SeaDataCloud/"
datafile = joinpath(datadir, "data_from_SDN_2015-09_TS_Atlantic_QC_done_v2.nc")
smalldata = joinpath(datadir, "smallData.txt")
smalldatanc = joinpath(datadir, "smallData.nc")

@time obsval2, obslon2, obslat2, obsdepth2, obstime2, obsid2 = NCODV.load(Float64, smalldatanc, "Water body salinity");

@time obsval, obslon, obslat, obsdepth, obstime, obsid = NCODV.load(Float64,
    datafile, "Water body salinity");

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
depthr = [0.,20.,50.];

varname = "Salinity"
yearlist = [1900:2017];
# monthlist = [[1,2,3],[4,5,6],[7,8,9],[10,11,12]];  # Seasonal climatology
monthlist = [1,2,3,4,5,6,7,8,9,10,11,12];  # Monthly climatology
monthlist = [1]
TS = DIVAnd.TimeSelectorYearListMonthList(yearlist,monthlist);
@show TS;

obslon[obslon.>180.] = obslon[obslon.>180.] .- 360.;
@show extrema(obslon);

coords = [(x,y) for (x,y) in zip(obslon, obslat)];
coords_u = unique(coords);
@info("Total number of coordinates: $(length(coords))")
@info("Number of unique coordinates (profiles): $(length(coords_u))")

obslon_u = [x[1] for x in coords_u];
obslat_u = [x[2] for x in coords_u];

checkobs((obslon,obslat,obsdepth,obstime),obsval,obsid)

bathname = "./data/gebco_30sec_16.nc"
# https://dox.ulg.ac.be/index.php/s/RSwm4HPHImdZoQP/download  gebco_30sec_4.nc
# https://dox.ulg.ac.be/index.php/s/wS6Y8P8NhIF60eG/download  gebco_30sec_8.nc
# https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download  gebco_30sec_16.nc

if !isfile(bathname)
    download("https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download",bathname)
else
    @info("Bathymetry file already downloaded")
end

@time bx,by,b = load_bath(bathname,true,lonr,latr);


mask = falses(size(b,1),size(b,2),length(depthr))
for k = 1:length(depthr)
    for j = 1:size(b,2)
        for i = 1:size(b,1)
            mask[i,j,k] = b[i,j] >= depthr[k]
        end
    end
end
@show size(mask)

sz = (length(lonr),length(latr),length(depthr));
lenx = fill(100_000.,sz)   # 100 km
leny = fill(100_000.,sz)   # 100 km
lenz = fill(25.,sz);      # 25 m
len = (lenx, leny, lenz);
epsilon2 = 0.1;
#epsilon2 = epsilon2 * rdiag;

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
    # http://doi.org/10.12770/c7b53704-999d-4721-b1a3-04ec60c87238
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

    "documentation" => "http://dx.doi.org/doi_of_doc",

    # Digital Object Identifier of the data product
    "doi" => "...");

ncglobalattrib,ncvarattrib = SDNMetadata(metadata,filename,varname,lonr,latr);

if isfile(filename)
    rm(filename) # delete the previous analysis
    @info "Removing file $filename"
end

figdir = "./Atlantic/figures/"
if ~(isdir(figdir))
    mkpath(figdir);
    @info("Creating directory $(figdir)")
else
    @info("Figure directory already exists")
end

function plotres(timeindex,sel,fit,erri)
    tmp = copy(fit)
    nx,ny,nz = size(tmp)
end

@time dbinfo = diva3d((lonr,latr,depthr,TS),
    (obslon,obslat,obsdepth,obstime), obsval,
    len, epsilon2,
    filename,varname,
    bathname=bathname,
    plotres = plotres,
    mask = mask,
    fitcorrlen = false,
    niter_e = 2,
    ncvarattrib = ncvarattrib,
    ncglobalattrib = ncglobalattrib
    );

DIVAnd.saveobs(filename,(obslon,obslat,obsdepth,obstime),obsid);

project = "SeaDataCloud";

cdilist = "CDI-list-export.zip"

if !isfile(cdilist)
   download("http://emodnet-chemistry.maris2.nl/download/export.zip",cdilist)
end

ignore_errors = true

# File name based on the variable (but all spaces are replaced by _)
xmlfilename = "Water_body_$(replace(varname," "=>"_")).4Danl.xml"

# generate a XML file for Sextant (only for )
#divadoxml(filename,varname,project,cdilist,xmlfilename,
#          ignore_errors = ignore_errors)

datadir = "../data"
figdir = "../figures"
isdir(datadir) ? @debug("Directory already exists") : mkpath(datadir)
isdir(figdir) ? @debug("Directory already exists") : mkpath(figdir)

function make_dox_url(fileid::AbstractString)
    doxurl = "https://dox.uliege.be/index.php/s/$(fileid)/download"
    return doxurl::String
end

function download_check(datafile::AbstractString, datafileURL::AbstractString)

    if !isfile(datafile)    
        @info("Download file $(datafile)")
        download(datafileURL, datafile)
    else
        @info "File already downloaded"
    end
end

OIfile = joinpath(datadir, "dan_field_obs.nc")
OIfileURL = make_dox_url("96B8MOQeIcaRUoV")
salinityprovencalfile = joinpath(datadir, "WOD-Salinity-Provencal.nc")
salinityprovencalfileURL = make_dox_url("PztJfSEnc8Cr3XN")
salinitybigfile = joinpath(datadir, "Salinity.bigfile")
salinitybigfileURL = make_dox_url("k0f7FxA7l5FIgu9")

gebco04file = joinpath(datadir, "gebco_30sec_4.nc")
gebco04fileURL = make_dox_url("RSwm4HPHImdZoQP")
gebco08file = joinpath(datadir, "gebco_30sec_8.nc")
gebco08fileURL = make_dox_url("U0pqyXhcQrXjEUX")
gebco16file = joinpath(datadir, "gebco_30sec_16.nc")
gebco16fileURL = make_dox_url("U0pqyXhcQrXjEUX")
emodnetfile = joinpath(datadir, "combined_emodnet_bathymetry.nc")
emodnetfileURL = make_dox_url("pujUAyo9kTPO8oF")

adriaticfile = joinpath(datadir, "AdriaticSea_SDC.nc")
adriaticfileURL = make_dox_url("IRYJyNZ5KuKVoQL")

naodatafile = joinpath(datadir, "nao_station_annual.txt")
naodatafileURL = make_dox_url("zYVldQgtso1nMZg")

danfile = joinpath(datadir, "dan_field.mat")
danfileURL = make_dox_url("KLuPQ848PdMBz1J")
gribfile = joinpath(datadir, "test.grib")
gribfileURL = "https://github.com/weech/GRIB.jl/raw/master/test/samples/regular_latlon_surface.grib2"
geojsonfile = joinpath(datadir, "contour.json")
geojsonfileURL = make_dox_url("4vPeJM9NiIqPDuu")
geotifffile = joinpath(datadir, "Adriatic-2024-09-16T00_00_00Z.tif")
geotifffileURL = make_dox_url("tz9lCANaNIj3iG2")

smallODVfile = joinpath(datadir, "small_ODV_sample.txt")
smallODVfileURL = make_dox_url("n7wDAB7G6IWWZtl")
smallODVncfile = joinpath(datadir, "small_ODV_sample.nc")
smallODVncfileURL = make_dox_url("ugfCUjKlUollczU")

WODdatafile = joinpath(datadir, "WOD-temporary-dir.tar.gz")
WODdatafileURL = make_dox_url("8tRk0NAStr2P70j")
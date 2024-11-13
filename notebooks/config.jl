using Downloads


datadir = "../data"
figdir = "../figures"
outputdir = "../output/"
mkpath.([datadir, figdir, outputdir])

function make_dox_url(fileid::AbstractString)
    doxurl = "https://dox.uliege.be/index.php/s/$(fileid)/download"
    return doxurl::String
end

function download_check(datafile::AbstractString, datafileURL::AbstractString)

    if !isfile(datafile)    
        @info("Download file $(datafile)")
        Downloads.download(datafileURL, datafile)
    else
        @info "File already downloaded"
    end
end

function plot_bathy(bx, by, b; xticks=2.:1.:14, yticks=42.:1.:45.)
    fig = GeoMakie.Figure()
    ga = GeoAxis(fig[1, 1];  dest = "+proj=merc", title = "GEBCO bathymetry", xticks=xticks, yticks=yticks)
    hm = GeoMakie.heatmap!(ga, bx, by, b, interpolate = false)
    GeoMakie.xlims!(ga, (bx[1], bx[end]))
    GeoMakie.ylims!(ga, (by[1], by[end]))
    GeoMakie.contour!(ga, bx, by, b, levels=[0.], color=:black)
    Colorbar(fig[2, 1], hm, vertical = false, label = "(m)")
    fig
end

"""
    plot_mask(bx, by, mask, depth)

Plot the land-sea mask `mask` on the grid defined by `bx` and `by`, at the depth level `depth` (in meters).
"""
function plot_mask(bx, by, mask; xticks=2.:1.:14, yticks=42.:1.:45., depth="")
    fig = GeoMakie.Figure()
    if length(depth) == 0
        figtitle = "Land-sea mask"
    else
        figtitle = "Land-sea mask at depth $(depth) m"
    end
    ga = GeoAxis(fig[1, 1];  dest = "+proj=merc", title = figtitle, xticks=xticks, yticks=yticks)
    hm = GeoMakie.heatmap!(ga, bx, by, mask, colormap=Reverse(:binary))
    GeoMakie.xlims!(ga, (bx[1], bx[end]))
    GeoMakie.ylims!(ga, (by[1], by[end]))
    fig
end

# Data files
OIfile = joinpath(datadir, "dan_field_obs.nc")
OIfileURL = make_dox_url("96B8MOQeIcaRUoV")
salinityprovencalfile = joinpath(datadir, "WOD-Salinity-Provencal.nc")
salinityprovencalfileURL = make_dox_url("PztJfSEnc8Cr3XN")
salinitybigfile = joinpath(datadir, "Salinity.bigfile")
salinitybigfileURL = make_dox_url("k0f7FxA7l5FIgu9")
adriaticfile = joinpath(datadir, "AdriaticSea_SDC.nc")
adriaticfileURL = make_dox_url("IRYJyNZ5KuKVoQL")

# Bathymetry files
gebco04file = joinpath(datadir, "gebco_30sec_4.nc")
gebco04fileURL = make_dox_url("RSwm4HPHImdZoQP")
gebco08file = joinpath(datadir, "gebco_30sec_8.nc")
gebco08fileURL = make_dox_url("wS6Y8P8NhIF60eG")
gebco16file = joinpath(datadir, "gebco_30sec_16.nc")
gebco16fileURL = make_dox_url("U0pqyXhcQrXjEUX")
emodnetfile = joinpath(datadir, "combined_emodnet_bathymetry.nc")
emodnetfileURL = make_dox_url("pujUAyo9kTPO8oF")

adriaticfile = joinpath(datadir, "AdriaticSea_SDC.nc")
adriaticfileURL = make_dox_url("IRYJyNZ5KuKVoQL")
balticfile = joinpath(datadir, "Baltic_obs.nc")
balticfileURL = make_dox_url("h0KlmTNzEp76ari")

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
smallODVsamplefile = joinpath(datadir, "small_ODV_sample.txt")
smallODVsamplefileURL = make_dox_url("5FdKh6Md0VAjsIU")

WODdatafile = joinpath(datadir, "WOD-temporary-dir.tar.gz")
WODdatafileURL = make_dox_url("8tRk0NAStr2P70j")

outputsalinity = joinpath(outputdir, "Water_body_Salinity.4Danl.nc")
outputsalinityURL = make_dox_url("h8d3pyqmuea6J9H")

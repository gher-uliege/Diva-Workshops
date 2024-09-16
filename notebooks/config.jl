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

adriaticfile = joinpath(datadir, "AdriaticSea_SDC.nc")
adriaticfileURL = make_dox_url("IRYJyNZ5KuKVoQL")

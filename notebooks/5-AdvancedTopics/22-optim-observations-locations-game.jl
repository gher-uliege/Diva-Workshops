# # Illustration of DIVAnd

# The aim of this notebook is to choose the location of 100 observations to
# optimally reconstruct the provided sea surface temperature anomaly using DIVAnd.
# We use the Reynolds et al. 2002 [OI SST](https://www.psl.noaa.gov/data/gridded/data.noaa.oisst.v2.html) for the month January and remove the zonal average. This is assumed to be the "true field" in the followed.
#
# 1. You should work in groups. Choose a group name and adapt the `groupname` accordingly
# 2. Please change only the marked code (after "Your turn !" and before "Do not make any change below")
# 3. You choose:
#      * the location of 100 observations (the vectors `xobs` and `yobs` which corresponds to longitude in degrees East and latitude in degrees North)
#      * the correlation length `len`
#      * the uncertainty of the observation `epsilon2`
# 4. You are allowed to guide your choice by using the true field `v` (the target variable)
# 5. Your results must be reproducible (the locations of the observations are saved in a text file at the end of the notebook)
# 6. You can submit as many test as you wish, only the best result with lowest root mean square (RMS) error is shown.
#
#
# First load all modules

using DIVAnd
using PyPlot
using NCDatasets
using Statistics
using Random
using Downloads: download
using Interpolations
using DelimitedFiles

# Download the data file if necessary

filename = "sst.ltm.1961-1990.nc"
if !isfile(filename)
    download("https://dox.ulg.ac.be/index.php/s/ptfCNIWGfJ247Gj/download",filename);
end

# Load the data

ds = NCDataset(filename)
vfull = reverse(nomissing(ds["sst"][:,:,1],NaN),dims=2)
lon = ds["lon"][:]
lat = reverse(ds["lat"][:])
close(ds);

# The array `mask` is 1 on sea and 0 on land

mask = isfinite.(vfull);

# Remove the zonal average

v0 = copy(vfull)
v0[.!mask] .= 0
v = vfull .- sum(v0,dims=1) ./ sum(mask,dims=1)
sz  = size(v)
xi,yi =  DIVAnd.ndgrid(lon,lat);

# The scale factors (inverse of the resolution)

pm = ones(sz) ./ ((xi[2,1]-xi[1,1]) .* cosd.(yi));
pn = ones(sz) / (yi[1,2]-yi[1,1]);

# Number of observations

nobs = 100

# Noise on observations [°C]

noise = 0.5

# ## Your turn !
#
# You can change the following code and variables

# your group name (better use only ASCII symbols)
groupname = "Just-a-test"
# Correlation length in arc degrees (1° ~ 111 km)
len = 20
# Uncertainty of the observation [adimensional]
epsilon2 = 0.001
# Choose 100 random location (only sea points)
# Is there a better way?
indexobs = shuffle(findall(mask[:] .== 1))[1:nobs];
xobs = xi[indexobs];
yobs = yi[indexobs];

# ## Do not make any change below

# Extract the pseudo-observations

xobs = mod.(xobs,360)
itp = interpolate((lon,lat), v, Gridded(Constant()))
vobs = itp.(xobs,yobs);

# Add some noise

Random.seed!(42)
vobs_perturbed = vobs + noise * randn(nobs);

# Make the analysis

vi,s = DIVAndrun(
    mask,(pm,pn),(xi,yi),(xobs,yobs),
    vobs_perturbed,
    len,epsilon2
);


# Plot the results

figure(figsize = (7.8,5.6))
function map(; cl = extrema(filter(isfinite,v)))
    axis("equal")
    xlim(extrema(lon))
    ylim(extrema(lat))
    clim(cl)
    colorbar(orientation="horizontal")
    contourf(xi,yi,mask,levels = [0,.5],cmap = "gray")
end
subplot(2,2,1)
pcolormesh(xi,yi,v); title("True field")
map()
subplot(2,2,2)
scatter(xi[indexobs],yi[indexobs],2,vobs,edgecolor="w",linewidth=0.);
title("Observation")
map()
subplot(2,2,3)
pcolormesh(xi,yi,vi); title("Analysis field")
map()
subplot(2,2,4)
pcolormesh(xi,yi,vi - v,cmap="RdBu"); title("Analysis - true field")
map(cl = (-3,3));


# RMS difference between analysis and true field

RMS_difference = sqrt(mean(filter(isfinite,(vi - v).^2)))

# A function to submit the RMS error to score board:
# http://data-assimilation.net/scores/?game=DIVAnd2022

function submit_results(groupname,rms_velocity)
    function myescape(str)
        for (s1,s2) in Dict("{" => "%7B", "}" => "%7D", "\"" => "%22", " " => "%20")
            str = replace(str,s1 => s2)
        end
        return str
    end
    myjson(data) = "{" * join(["\"$k\":$(string(v))" for (k,v) in data],",") * "}"
    game = "DIVAnd2022"

    data_dict = Dict()
    #=
    data = JSON.json(data_dict)
    groupname_esc = URIParser.escape(groupname)
    data_esc = URIParser.escape(data)
    =#
    data = myjson(data_dict)
    groupname_esc = myescape(groupname)
    data_esc = myescape(data)
    baseurl = "http://data-assimilation.net/scores"
    URL = "$(baseurl)/new?game=$(game)&name=$(groupname_esc)&value=$(rms_velocity)&data=$(data_esc)"
    rm(download(URL))
    println("Check scores at: $(baseurl)/?game=$(game)\n")
end

submit_results(groupname,RMS_difference)

filename = "positions-rms-RMS-$RMS_difference-len-$len-epsilon2-$epsilon2.txt"
writedlm(filename,[xobs  yobs])

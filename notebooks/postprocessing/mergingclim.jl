using NCDatasets
using Dates
using Glob
using GridInterpolations
using Interpolations
using Missings
"""
create_nc_merged(filename, longrid, latgrid, depthgrid, timegrid)

Create a netCDF file named `filename` with the coordinates taken from vectors
longrid, latgrid, depthgrid, timegrid.

The interpolated variable will be written by another function.
"""
function create_nc_merged(filename::String, longrid, latgrid, depthgrid, timegrid)
    ds = Dataset(joinpath(outputdir, outputfile), "c")

    # Dimensions
    ds.dim["lon"] = length(longrid)
    ds.dim["nv"] = 2
    ds.dim["lat"] = length(latgrid)
    ds.dim["depth"] = length(depthgrid)
    ds.dim["time"] = length(timegrid)

    # Declare variables
    nclon = defVar(ds,"lon", Float64, ("lon",))
    nclon.attrib["standard_name"] = "longitude"
    nclon.attrib["long_name"] = "longitude"
    nclon.attrib["units"] = "degrees east"
    nclon.attrib["axis"] = "X"
    nclon.attrib["valid_min"] = -180.
    nclon.attrib["valid_max"] = 180.

    nclon_bnds = defVar(ds,"lon_bnds", Float64, ("nv", "lon"))

    nclat = defVar(ds,"lat", Float64, ("lat",))
    nclat.attrib["standard_name"] = "latitude"
    nclat.attrib["long_name"] = "latitude"
    nclat.attrib["units"] = "degrees north"
    nclat.attrib["axis"] = "Y"
    nclat.attrib["valid_min"] = -90.
    nclat.attrib["valid_max"] = 90.

    nclat_bnds = defVar(ds,"lat_bnds", Float64, ("nv", "lat"))

    ncdepth = defVar(ds,"depth", Float64, ("depth",))
    ncdepth.attrib["standard_name"] = "depth"
    ncdepth.attrib["units"] = "meters"
    ncdepth.attrib["axis"] = "Z"
    ncdepth.attrib["positive"] = "down"

    ncdepthnew_bnds = defVar(ds,"depthnew_bnds", Float64, ("nv", "depth"))

    nctime = defVar(ds,"time", Float64, ("time",))
    nctime.attrib["standard_name"] = "time"
    nctime.attrib["bounds"] = "time3_bnds"
    nctime.attrib["units"] = "days since 1900-01-01 00:00:00"
    nctime.attrib["calendar"] = "standard"
    nctime.attrib["climatology"] = "climatology_bounds"

    ncclimatology_bounds = defVar(ds,"climatology_bounds", Float64, ("nv", "time"))
    ncclimatology_bounds.attrib["units"] = "days since 1900-01-01 00:00:00"
    ncclimatology_bounds.attrib["calendar"] = "standard"

    # Interpolated variable
    # (should be obtained from one of the regional netCDF files)
    ncvarinterp = defVar(ds,"Water_body_ammonium", Float32, ("lon", "lat", "depth", "time"))
    ncvarinterp.attrib["long_name"] = "Water_body_ammonium"
    ncvarinterp.attrib["_FillValue"] = Float32(-9999.)
    ncvarinterp.attrib["missing_value"] = Float32(-9999.)
    ncvarinterp.attrib["actual_range"] = "0,125"
    ncvarinterp.attrib["units"] = "umol/l"

    # Global attributes
    ds.attrib["Conventions"] = "CF-1.0"
    ds.attrib["title"] = "DIVA 4D analysis of Water_body_ammonium"
    ds.attrib["product_id"] = product_id
    ds.attrib["abstract"] = "Merge netCDF product obtained from the Arctic, Atlantic, Baltic, Black, Mediterranean and North seas"
    ds.attrib["Creation date"] = Dates.format(Dates.now(),  "yyyy-mm-dd HH:MM:SS")
    ds.attrib["Authors"] = "GHER, University of Liège"

    nclat[:] = latgrid;
    nclon[:] = longrid;
    nctime[:] = timegrid;
    ncdepth[:] = depthgrid;

    close(ds)
end


"""
get_file_list(datadir, varname, season)

Return a list of files located in `datadir`, containing the
variable `varname` for the season `season`.

```julia
get_file("./data/EMODnet/", "chlorophyll-a", "Winter")
```
"""
function get_file_list(datadir::String, varname::String="", season::String="")::Array
    filelist = []
    for (root, dirs, files) in walkdir(datadir)
        for file in files
            if endswith(file, ".nc") &
                occursin(varname, file) &
                occursin(uppercasefirst(season), root)
                push!(filelist, joinpath(root, file))
            end
        end
    end
    return filelist
end


"""
get_years(filename)

Extract the years (from the time variable) out of a netCDF file
"""
function get_years(filename::String)::Array
    ds = Dataset(filename,"r")
    dategrid = ds["time"][:]
    yeargrid = unique(Dates.year.(dategrid))
    close(ds)
    return yeargrid
end


"""
```julia
get_closer_depth(depthgrid, depthlevel)
```
Get the 2 closest depths in vector `depthgrid`, to a select depth level `depthlevel`
If `depthlevel` is outside the interval defined by `depthgrid`, then nothing is returned.

## Examples
```julia
get_closer_depth([-10., -5., 7., 20], 1.);
(-5., 7.)
```

```julia
get_closer_depth([-10., -5., 7., 20], 1.);
(-5., 7.)
```
"""
function get_closer_depth(depthgrid::Array, depthlevel::Float64)
    # Check if we are within the depth interval
    if depthlevel >= minimum(depthgrid) && depthlevel <= maximum(depthgrid)
        Δdepth =  depthgrid .- depthlevel
        depthbelow = maximum(Δdepth[Δdepth .< 0]) + depthlevel
        depthabove = minimum(Δdepth[Δdepth .> 0]) + depthlevel;
        @debug("Depth below: " * string(depthbelow) * " m")
        @debug("Depth above: " * string(depthabove) * " m")
    else
        depthbelow = nothing
        depthabove = nothing
    end

    return depthbelow, depthabove
end

"""
```julia
w1, w2 = get_depth_weights(depthlevel, dmin, dmax)
```
Compute the weight for the linear interpolation, according to the depths.
If `depthlevel` is outside the interval defined by `dmin` and `dmax`,
then nothing is returned.

## Example
```julia
w1, w2 = get_depth_weights(-5., -20., 0.)
(0.75, 0.25)
```
"""
function get_depth_weights(depthlevel::Float64, dmin::Float64, dmax::Float64)
    if depthlevel <= dmax && depthlevel >= dmin
        Δ = dmax - dmin
        w1 = (depthlevel - dmin) / Δ
        w2 = 1 - w1
    else
        w1 = nothing
        w2 = nothing
    end

    return w1, w2
end

"""
```julia
get_depth_indices(depth, depthvector)
```
Return the indices of the depth levels from `depthvector` above and below
the depth level `depth`
"""
function get_depth_indices(depth::Float64, depthvector::Array{Float64})
    dmin, dmax = get_closer_depth(depthvector, depth)
    if dmin == nothing || dmax == nothing
        indmin = nothing
        indmax = nothing
    else
        indmin = findall(depthvector .== dmin)[1]
        indmax = findall(depthvector .== dmax)[1]
    end
    return indmin, indmax
end


"""
```julia
depth_interp(depth, depthvector, field)
```
Perform linear interpolation of the 4D variable `field` (read from a netCDF) defined on the
levels `depthvector` (vector) onto the depth level `depth`.

## Example
```julia
depth_interp(25., (0., 10., 20., 30.), temperature)
```
"""
function depth_interp(depth::Float64, depthvector::Array{Float64}, field::Array{Float64})
    dmin, dmax = get_closer_depth(depthvector, depth)
    indmin, indmax = get_depth_indices(depth, depthvector)
    # Compute weigths
    w1, w2 = get_depth_weights(depth, dmin, dmax)
    # Perform interpolation
    fieldinterp = w1 * field[:,:,indmin,:] + w2 * field[:,:,indmax,:]
    return fieldinterp
end

"""
```julia
interp_horiz(londata, latdata, data, longrid, latgrid)
```
Perform a bilinear interpolation of a 2D field defined by the coordinates
`(londata, latdata)` and the values `data`, onto the grid defined by the
vectors `longrid` and `latgrid`.
The interpolation is only performed over the area where data are available,
i.e., no extrapolation is performed.

"""
function interp_horiz(londata, latdata, data, longrid, latgrid)

    # Find the coordinates where the interpolation can be performed
    # (no extrapolation)
    goodlon = (longrid .<= londata[end]) .& (longrid .>= londata[1]);
    goodlat = (latgrid .<= latdata[end]) .& (latgrid .>= latdata[1]);

    # Remove the missing values?
    # Ask Alex if necessary
    #londata = coalesce.(londata, NaN)
    #latdata = coalesce.(latdata, NaN)
    #data = coalesce.(data, NaN);
    #data = convert(Array{Float32,2}, data)

    # Create the interpolator
    itp = Interpolations.interpolate((londata, latdata), data, Gridded(Linear()))
    #fieldinterpolated = itp(longrid, latgrid);

    # Perform the interpolation
    # (only within the domain of interest)
    lon_interp = longrid[goodlon]
    lat_interp = latgrid[goodlat]
    field_interpolated = itp(lon_interp, lat_interp);

    return lon_interp, lat_interp, field_interpolated
end

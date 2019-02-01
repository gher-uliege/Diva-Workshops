using NCDatasets
using Dates
using Glob

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

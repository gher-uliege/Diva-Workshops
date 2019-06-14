**Tool:** nco (netCDF operator): http://nco.sourceforge.net/           
**Credit:** Ö. Bäck
 

### Mask an area 

The goal is to mask (i.e. set to land) an area after the DIVA analysis.      
The area to mask is specified by the indices in the coordinates.      
Note the quotes around the variable name (which contains spaces).
```bash
ncap2 -s "'ITS-90 water temperature'(:, :, 112:224, 0:15)=9.96921e36;" infile.nc outfile.nc
```
numbers are indices of the matrix that consist of dimensions (time, depth, lat, lon), so the above masks an area specified by `lat[112:224]` and `lon[0:15]` at all depth and time steps.

### Cut the netCDF

```bash
ncks -d lon,10.,31. infile.nc outfile.nc
```
numbers here specify min and max of what you want, so anything outside 10 and 31 degrees are removed from all fields in the netCDF and also in the lon variable.

## Recommendation for the preparation of products


### File and variable naming

`DIVA` and `DIVAnd` have been adapted to accept file and variable names with white spaces. However it is recommended to avoid them, for example by substituting the white spaces with underscores.

```
Sea water temperature → Sea_water_temperature
```

Note that issues can arise from the white spaces when using *Thredds* data server.

### Keep things simple

Both `DIVA` and `DIVAnd` offer a large amount of tools and sophisticated options (variable correlation length, detrending, advection) that can improve the final results.

However it is recommended to always start with a simple application (constant parameters, no advection, no data transformation etc) to ensure things are working as expected and the results make sense.

### Domain choice

1. Final users tend to prefer simple, *rectangular* domains, i.e. delimited by lines of constant longitudes or latitudes.
2. If merged products have to be created, it is necessary to ensure that we can have a smooth transition between them.

If there is a need for a domain delimitation following the irregular shapes, it may be relevant to have post-processing tools provided to the interested users.

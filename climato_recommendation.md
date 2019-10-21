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

### Harmonisation

The goal is to ensure consistency, taking into account the regional specificities.     
Main axis:
1. Data sources,
2. Interpolation tool,
3. Procedure and parameters.

#### Data sources

Try to have a consistent approach: same dataset(s) for each region and a comparable method for the duplicate removal.

<img src="./figures/datasources.png" class="img-responsive">

* Which data source(s)?
* Which version for each dataset?
* How to eliminate **duplicates**?

#### Domain choice

1. Final users tend to prefer simple, *rectangular* domains, i.e. delimited by lines of constant longitudes or latitudes.
2. If merged products have to be created, it is necessary to ensure that we can have a smooth transition between them.

<img src="./figures/EMODnet_domains05.png" class="img-responsive">

If there is a need for a domain delimitation following the irregular shapes, it may be relevant to have post-processing tools provided to the interested users.

#### Interpolation tool

* Julia version: >= 1.0 (now at 1.2)
* DIVAnd version: >= v2.1.0 (now at v2.4.0)

#### Procedure & parameters

**Domain:**         
Spatial resolution: depending on region     
Total time coverage: depending on region     
Decade definitions: consistency      
Vertical levels: consistency across regions      

**Basic parameters:**     
Bathymetry: GEBCO or EMODnet Bathymetry, resolution depending on domain      
Correlation length: optimized (if coverage allows)      
Noise-to-signal ratio: optimized (if coverage allows)      
Data weights: optional (check sensitivity on a few levels)      
Background field: to discuss (case by case)     

**Other parameters:**      
surfextend = true (vertical extension at surface)       
coeff_derivative2 = [0., 0., 10⁻⁸] (sensitivity test)       

### Speeding up things

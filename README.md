# DIVA Workshops and training

<div align="center"> <img src="./figures/divand_logo.png" alt="DIVAnd logo" width="200"></img></div>

[![Build Status](https://github.com/gher-uliege/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-uliege/Diva-Workshops/actions) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)      
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/gher-uliege/Diva-Workshops) ![GitHub contributors](https://img.shields.io/github/contributors/gher-uliege/Diva-Workshops) ![GitHub last commit](https://img.shields.io/github/last-commit/gher-uliege/Diva-Workshops)     
[![Static Badge](https://img.shields.io/badge/Project-FAIR--EASE-blue)](https://www.fairease.eu/) [![Static Badge](https://img.shields.io/badge/Project-SeaDataCloud-blue)](https://www.seadatanet.org) [![Static Badge](https://img.shields.io/badge/Project-IRISCC-blue)](https://www.iriscc.eu/) [![Static Badge](https://img.shields.io/badge/Project-AQUARIUS-blue)](https://aquarius-ri.eu/)

## Objective

The goal of the training material module, made up of [Jupyter](https://jupyter.org/) notebooks, is twofold: 
1. provide the users with a basic knowledge of Julia, meaning they are capable of reading the code presented in the notebooks, but also install new modules, write basic functions for processing or create basic plots. 
2. endure that the users to able to create their own products (i.e. climatologies) using the [`DIVAnd`](https://github.com/gher-uliege/divand.jl) software tool, by combining their own datasets with those from other sources (for instance the World Ocean Database) and setting the analysis parameters according to their region of interest.

More information about `DIVAnd` is available in the package [documentation](https://gher-uliege.github.io/DIVAnd.jl/stable/).

### Content

The notebooks are organised into 4 categories, according to their main objectives and following the "Instructional design" described in the associated paper in JOSE.    
The different notebook folders can be covered independently, depending on the experise of the users.       
Suggestions for the number of sessions and time to be dedicated for each category are provide below.

| Folder | Content | Recommended duration |
|:-------------------|:----------------------:|----------------|
[1-Intro](./notebooks/1-Intro/) | Know the basics commands in Julia, read/write netCDF files and create different types of plots (scatter, histograms, maps, ...) | 2 hours |
[2-Preprocessing](./notebooks/2-Preprocessing) | Learn about the input file preparation: observations (download and reading), bathymetry and mask, time periods, ... | 4 hours |
[3-Analysis](./notebooks/3-Analysis/) | Perform different types of analysis, optimise the analysis parameters and work with different coordinate systems | 2 sessions of 4 hours   |
[4-AdvancedTopics](./notebooks/4-AdvancedTopics/) | Discover more complex types of analysis, using for instance advection or inequality constraints. | 4 hours  |

<details>

<summary><h3>Full list of notebooks</h3></summary>

[1-01-notebooks-basics.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/1-Intro/1-01-notebooks-basics.ipynb)         
[1-02-Julia-introduction.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/1-Intro/1-02-Julia-introduction.ipynb)          
[1-03-netCDF.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/1-Intro/1-03-netCDF.ipynb)           
[1-04-OI-variational-analysis-introduction.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/1-Intro/1-04-OI-variational-analysis-introduction.ipynb)        
[1-05-plots-maps.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/1-Intro/1-05-plots-maps.ipynb)           
[2-01-topography.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/2-Preprocessing/2-01-topography.ipynb)              
[2-02-reading-data.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/2-Preprocessing/2-02-reading-data.ipynb)           
[2-03-data-downloading.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/2-Preprocessing/2-03-data-downloading.ipynb)           
[2-04-ODV-data-import.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/2-Preprocessing/2-04-ODV-data-import.ipynb)              
[2-05-defining-time-periods.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/2-Preprocessing/2-05-defining-time-periods.ipynb)         
[3-01-L-and-epsilon-effect.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-01-L-and-epsilon-effect.ipynb)          
[3-02-correlation-length.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-02-correlation-length.ipynb)          
[3-03-processing-parameter-optimization.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-03-processing-parameter-optimization.ipynb)         
[3-04-processing-quality-check.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-04-processing-quality-check.ipynb)       
[3-05-cpme-demo.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-05-cpme-demo.ipynb)        
[3-06-errormaps-demo.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-06-errormaps-demo.ipynb)        
[3-07-example-analysis.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-07-example-analysis.ipynb)          
[3-08-background-field.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-08-background-field.ipynb)          
[3-09-full-analysis.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-09-full-analysis.ipynb)           
[3-10-save_attributes_EMODnet.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-10-save_attributes_EMODnet.ipynb)        
[3-11-generalized-vertical-coordinates.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-11-generalized-vertical-coordinates.ipynb)          
[3-12-sigma-layers.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-12-sigma-layers.ipynb)         
[3-13-polar-coordinates.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-13-polar-coordinates.ipynb)         
[3-14-Sphericalcoordinates.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-14-Sphericalcoordinates.ipynb)          
[3-15-analysis-datapoints.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/3-Analysis/3-15-analysis-datapoints.ipynb)        
[4-01-relative-correlation-length.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-01-relative-correlation-length.ipynb)          
[4-02-average-background.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-02-average-background.ipynb)          
[4-03-heatmaps.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-03-heatmaps.ipynb)           
[4-04-heatmapsCV.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-04-heatmapsCV.ipynb)         
[4-05-turtles-tensity-map.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-05-turtles-tensity-map.ipynb)           
[4-06-advection_constrain.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-06-advection_constrain.ipynb)         
[4-07-advection_constraint_Adriatic.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-07-advection_constraint_Adriatic.ipynb)           
[4-08-source-term.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-08-source-term.ipynb)          
[4-09-open-boundary-conditions.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-09-open-boundary-conditions.ipynb)          
[4-10-multivariate-EOF.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-10-multivariate-EOF.ipynb)           
[4-11-multivariate-Jacobian.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-11-multivariate-Jacobian.ipynb)         
[4-12-analysis-with-cycles.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-12-analysis-with-cycles.ipynb)          
[4-13-BlackSea-detrend-geostrophic.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-13-BlackSea-detrend-geostrophic.ipynb)           
[4-14-inequalities-constrains.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-14-inequalities-constrains.ipynb)       
[4-15-geostrophytest.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-15-geostrophytest.ipynb)       
[4-16-Lshape.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-16-Lshape.ipynb)          
[4-17-interp-section.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-17-interp-section.ipynb)         
[4-18-make-paper-figure.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-18-make-paper-figure.ipynb)          
[4-19-optim-observations-locations-game.ipynb](https://github.com/gher-uliege/Diva-Workshops/blob/main/notebooks/4-AdvancedTopics/4-19-optim-observations-locations-game.ipynb)          
</details>

### How to use or adopt the notebooks?

Different paths can be taken, depending on your experience with Julia and with `DIVAnd`.   
First follow the instructions for the installation, then decide from where to start according to your experience or your audience.      

| Experience in Julia | Experience with DIVAnd | Recommendation |
|:-------------------:|:----------------------:|----------------|
|         No          |           No           | Start from the beginning! |
|         Yes         |           No           | Start with the [2-Preprocessing](./notebooks/2-Preprocessing) notebooks, then try an analysis (for instance [3-07-example-analysis.ipynb](./notebooks/3-Analysis/3-07-example-analysis.ipynb)) |
|         No          |           Yes          | Check the [1-Intro](./notebooks/1-Intro/) notebooks to get familiar with Julia, then play with the [analysis](./notebooks/3-Analysis/3-09-full-analysis.ipynb)             |
|         Yes         |           Yes          | Use the notebook [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb) as a starting point for your analysis, then play with the [4-AdvancedTopics](./notebooks/4-AdvancedTopics/) |

#### 🚀 Fast start

If you had to use only one notebook, it should be this one: [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb)

### How to contribute?

Please refer to the instructions in [CONTRIBUTING.md](CONTRIBUTING.md).

## Installation

### Julia 

Julia language can be installed using `juliaup`, as detailed in the [Download](https://julialang.org/downloads/) section of Julia.

### Jupyter

Jupyter has to be installed in order to have a notebook interface. It can be installed and launched (in Julia) with the following command in the Pkg REPL      
(Enter the Pkg REPL by pressing `]` from the Julia session):
```julia
(@v1.11) pkg> add IJulia
```
> [!WARNING]
> After an update of the Julia version, one can face an error message related to the Kernel:<br>
`LoadError: ArgumentError: Package IJulia ... is required but does not seem to be installed` <br>
This can be solved with the command:
```julia
using IJulia
installkernel("Julia")
```

### The notebooks 

To get the notebooks on your computer you can either:
1. Download a [zipped archive](https://github.com/gher-uliege/Diva-Workshops/archive/master.zip) and uncompress it [for any user].
2. Clone the whole directory: `git clone git@github.com:gher-uliege/Diva-Workshops.git` (for git users).
> [!NOTE] 
> The notebooks will get dependencies via the file `Project.toml`. This is why all the notebooks start with the commands
```julia
import Pkg
Pkg.activate("../..")
Pkg.instantiate()
```

The Jupyter session is started with:
```julia
using IJulia
notebook()
```


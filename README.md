# DIVA Workshops and training

<div align="center"> <img src="./figures/divand_logo.png" alt="DIVAnd logo" width="200"></img></div>

[![Build Status](https://github.com/gher-uliege/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-uliege/Diva-Workshops/actions) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)      
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/gher-uliege/Diva-Workshops) ![GitHub contributors](https://img.shields.io/github/contributors/gher-uliege/Diva-Workshops) ![GitHub last commit](https://img.shields.io/github/last-commit/gher-uliege/Diva-Workshops)     
[![Static Badge](https://img.shields.io/badge/Project-FAIR--EASE-blue)](https://www.fairease.eu/) [![Static Badge](https://img.shields.io/badge/Project-SeaDataCloud-blue)](https://www.seadatanet.org) [![Static Badge](https://img.shields.io/badge/Project-IRISCC-blue)](https://www.iriscc.eu/) [![Static Badge](https://img.shields.io/badge/Project-AQUARIUS-blue)](https://aquarius-ri.eu/)

## Objective

The [Jupyter](https://jupyter.org/) notebooks contained in this repository help users to create gridded fields from in situ observations using the [`DIVAnd`](https://github.com/gher-uliege/divand.jl) software tool.     
More information about `DIVAnd` is available in the package [documentation](https://gher-uliege.github.io/DIVAnd.jl/stable/).

### Content

The notebooks are organised into 4 categories, according to their main objectives.

| Folder | Content | Recommended duration |
|:-------------------|:----------------------:|----------------|
[1-Intro](./notebooks/1-Intro/) | Know the basics commands in Julia, read/write netCDF files and create different types of plots (scatter, histograms, maps, ...) |  |
[2-Preprocessing](./notebooks/2-Preprocessing) | Learn about the input file preparation: observations (download and reading), bathymetry and mask, time periods, ... |  |
[3-Analysis](./notebooks/3-Analysis/) | Perform different types of analysis, optimise the analysis parameters and work with different coordinate systems |   |
[4-AdvancedTopics](./notebooks/4-AdvancedTopics/) | Discover more complex types of analysis, using for instance advection or inequality constraints. |   |

### How to use the notebooks?

Different paths can be taken, depending on your experience with Julia and with `DIVAnd`.

| Experience in Julia | Experience with DIVAnd | Recommendation |
|:-------------------:|:----------------------:|----------------|
|         No          |           No           | Start from the beginning! |
|         Yes         |           No           | Start with the [2-Preprocessing](./notebooks/2-Preprocessing) notebooks, then try an analysis (for instance [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb)) |
|         No          |           Yes          | Check the [1-Intro](./notebooks/1-Intro/) notebooks to get familiar with Julia, then play with the [analysis](./notebooks/3-Analysis/3-09-full-analysis.ipynb)             |
|         Yes         |           Yes          | Use the notebook [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb) as a starting point for your analysis, then play with the [4-AdvancedTopics](./notebooks/4-AdvancedTopics/) |


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
```
using IJulia
installkernel("Julia")
```

### The notebooks 

To get the notebooks on your computer you can either:
1. Download a [zipped archive](https://github.com/gher-uliege/Diva-Workshops/archive/master.zip) and uncompress it [for any user].
2. Clone the whole directory: `git clone git@github.com:gher-uliege/Diva-Workshops.git` (for git users).
> [!NOTE] 
> The notebooks will get dependencies via the file `Project.toml`. This is why all the notebooks start with the commands<br>
<code>
import Pkg<br>
Pkg.activate("../..")<br>
Pkg.instantiate()<br>
</code> 

The Jupyter session is started with:
```julia
using IJulia
notebook()
```

## Community guidelines

Please refer to the instructions in [CONTRIBUTING.md](CONTRIBUTING.md).
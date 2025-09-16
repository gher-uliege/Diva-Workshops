# DIVA Workshops and training

<div align="center"> <img src="./figures/divand_logo.png" alt="DIVAnd logo" width="200"></img></div>

[![Build Status](https://github.com/gher-uliege/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-uliege/Diva-Workshops/actions) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)      
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/gher-uliege/Diva-Workshops) ![GitHub contributors](https://img.shields.io/github/contributors/gher-uliege/Diva-Workshops) ![GitHub last commit](https://img.shields.io/github/last-commit/gher-uliege/Diva-Workshops)     
[![Static Badge](https://img.shields.io/badge/Project-FAIR--EASE-blue)](https://www.fairease.eu/) [![Static Badge](https://img.shields.io/badge/Project-SeaDataCloud-blue)](https://www.seadatanet.org) [![Static Badge](https://img.shields.io/badge/Project-IRISCC-blue)](https://www.iriscc.eu/) [![Static Badge](https://img.shields.io/badge/Project-AQUARIUS-blue)](https://aquarius-ri.eu/)

## Objective

The [Jupyter](https://jupyter.org/) notebooks contained in this repository are designed to explain users how to create gridded fields from in situ observations using the [`DIVAnd`](https://github.com/gher-uliege/divand.jl) software tool.

## Content

The notebooks are organised into 5 categories, separated in folders:
* [1-Intro](./notebooks/1-Intro/): know the basics commands in Julia, read/write netCDF files and create different types of plots (scatter, histograms, maps, ...).
* [2-Preprocessing](./notebooks/2-Preprocessing): learn about the input file preparation: observations (download and reading), bathymetry and mask, time periods, ...
* [3-Analysis](./notebooks/3-Analysis/): perform different types of analysis, optimise the analysis parameters and work with different coordinate systems.
* [4-AdvancedTopics](./notebooks/4-AdvancedTopics/): discover more complex types of analysis, using for instance advection or inequality constraints.

## How to use the notebooks?

Different paths can be taken, depending on your experience.

| Experience in Julia | Experience with DIVAnd | Recommendation |
|:-------------------:|:----------------------:|----------------|
|         No          |           No           | Start from the beginning! |
|         Yes         |           No           | Start with the [2-Preprocessing](./notebooks/2-Preprocessing) notebooks, then try an analysis (for instance [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb)) |
|         No          |           Yes          | Check the [1-Intro](./notebooks/1-Intro/) notebooks to get familiar with Julia, then play with the [analysis](./notebooks/3-Analysis/3-09-full-analysis.ipynb)             |
|         Yes         |           Yes          | Use the notebook [3-09-full-analysis.ipynb](./notebooks/3-Analysis/3-09-full-analysis.ipynb) as a starting point for your analysis, then play with the [4-AdvancedTopics](./notebooks/4-AdvancedTopics/) |


## Installation

### Julia 

Julia language can be installed using `juliaup`, as detailed in the "Download" section of the Julia web: https://julialang.org/downloads/.     
A Julia session is started by typing `julia` in the terminal or by clicking on the Julia shortcut in Windows.

```bash
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.11.3 (2025-01-21)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |
julia> 
```

### Jupyter

Jupyter has to be installed in order to have a notebook interface.        
It can be installed and launched (in Julia) with the following command in the Pkg REPL     
(Enter the Pkg REPL by pressing ] from the Julia session):

```julia
(@v1.11) pkg> add IJulia
```

## Running the notebooks

In a Julia session, execute the following commands:

```julia
using IJulia
notebook()
```
This will start a Jupyter session within your browser.      
Select the notebook located in `Diva-Workshops/notebooks/`.

## ℹ️ About DIVAnd

`DIVAnd` is **not** a new release of [`DIVA`](https://github.com/gher-uliege/DIVA), it is another software tool with different 

algorithms,      
functionalities and     
language.

For a single 2D analysis (surface salinity in the Black Sea) on Intel Xeon CPU E5-2650.     
DIVA was compiled with the Intel Fortran Compiler.

|     | DIVA - Fortran | DIVAnd - Julia |
|----|----------------|----------------|
| mesh             | triangular | structured | 
| deg. of freedom  |    236296 |  236317 |
| correlation length | 0.19    | 0.19 |
| CPU time | 43.8 s | 8.7 s |

However, a triangular mesh is greatly more flexible than a structured mesh and has $C_1$ continuity.       
The main advantage of `DIVAnd` is that it can work on more than just 2 dimensions (but the requirements of RAM memory increase also).

## Using DIVAnd without installing

### ☁️ On public servers (cloud)

`DIVAnd` has been made available in _Virtual Research Environments_ (VRE) in European projects.     
The deployment is performed using a Docker container.  

For instance `DIVAnd` can used in projects such as:
- [FAIR-EASE](https://fairease.eu/): the tool can be accessed from [Galaxy](https://earth-system.usegalaxy.eu/).
- [Blue Cloud 2026](https://blue-cloud.org/): the tool is available though [D4Science](https://www.d4science.org/). 

### Binder

Most notebooks need more resources that what is can currently available on Binder. The introduction notebooks (introduction to OI and variationa analysis) however work
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gher-uliege/Diva-Workshops/master?filepath=notebooks%2F1-Intro%2F1-04-OI-variational-analysis-introduction.ipynb).

## 🆘 Troubleshooting

### LoadError: ArgumentError: Package IJulia ... is required but does not seem to be installed

After an update of the Julia version, one can face an error message related to the Kernel.     
This can be solved with the command:

```
using IJulia
installkernel("Julia")
```

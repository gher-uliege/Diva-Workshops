[![Build Status](https://github.com/gher-uliege/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-uliege/Diva-Workshops/actions) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)          
[![Static Badge](https://img.shields.io/badge/Project-FAIR--EASE-blue)](https://www.fairease.eu/) ![Static Badge](https://img.shields.io/badge/Project-SeaDataCloud-blue)

# DIVA Workshops and training

<div align="center"> <img src="./figures/divand_logo.png"></img></div>

The [Jupyter](https://jupyter.org/) notebooks contained in this repository are designed to explain users how to create gridded fields from in situ observations using the [`DIVAnd`](https://github.com/gher-uliege/divand.jl) software tool.

The repository was firstly created to store the material for the [workshops](https://gher-uliege.github.io/Diva-Workshops/Previous-workshops.html) and training sessions organised in the frame of H2020 [SeaDataCloud](https://www.seadatanet.org/) project. The notebooks are also used in the [FAIR-EASE](https://fairease.eu/) project.   

## Installation

### Julia language

Julia language can be installed using `juliaup`, as detailed in the "Download" section of the Julia web: https://julialang.org/downloads/.     
A Julia session is started by typing `julia` in the terminal or by clicking on the Julia shortcut in Windows.

```bash
$ julia
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.11.1 (2024-10-16)
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

### On public servers (cloud)

`DIVAnd` has been made available in _Virtual Research Environments_ (VRE) in European projects.     
The deployment is performed using a Docker container.  

For instance `DIVAnd` can used in projects such as:
- [FAIR-EASE](https://fairease.eu/): the tool can be accessed from [Galaxy](https://earth-system.usegalaxy.eu/).
- [Blue Cloud 2026](https://blue-cloud.org/): the tool is available though [D4Science](https://www.d4science.org/). 

### Binder

Most notebooks need more resources that what is can currently available on Binder. The introduction notebooks (introduction to OI and variationa analysis) however work
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gher-uliege/Diva-Workshops/master?filepath=notebooks%2F1-Intro%2F04-OI-variational-analysis-introduction.ipynb).

## 🆘 Troubleshooting

### LoadError: ArgumentError: Package IJulia ... is required but does not seem to be installed

After an update of the Julia version, one can face an error message related to the Kernel.     
This can be solved with the command:

```
using IJulia
installkernel("Julia")
```
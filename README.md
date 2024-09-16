[![Build Status](https://github.com/gher-uliege/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-uliege/Diva-Workshops/actions) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
![GitHub top language](https://img.shields.io/github/languages/top/gher-uliege/Diva-Workshops)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)          
[![Static Badge](https://img.shields.io/badge/Project-FAIR--EASE-blue)](https://www.fairease.eu/) ![Static Badge](https://img.shields.io/badge/Project-SeaDataCloud-blue)

# DIVA Workshops and training

This repository provides a set of [Jupyter](https://jupyter.org/) notebooks (examples and exercises) for the `DIVAnd` user workshops and training sessions organised in the frame of H2020 [SeaDataCloud](https://www.seadatanet.org/) project. The notebooks are also used in the [FAIR-EASE](https://fairease.eu/) project.    

[`DIVA`](https://github.com/gher-uliege/DIVA) and [`DIVAnd`](https://github.com/gher-uliege/divand.jl) are software tools designed to generate gridded fields from in-situ observations.

## Workshops

| Event      | Location      | Dates      |
| ------------- | ------------- | ------------- |
|  [1st workshop](https://gher-uliege.github.io/Diva-Workshops/Previous/Diva-workshop-2018-Liege.html) | Liège 🇧🇪 | 3-6 April 2018 |
|  2nd SeaDataCloud training course | Ostend 🇧🇪 | 19-26 June 2019 | 
| [2nd workshop](https://gher-uliege.github.io/Diva-Workshops/2020/) | Bologna 🇮🇹 | 27-30 January 2020 |

## About DIVAnd

`DIVAnd` is **not** a new release of [`DIVA`](https://github.com/gher-uliege/DIVA), it is another software tool with different 

algorithms,      
functionalities and     
language.

### Let's compare apples and oranges

![](./notebooks/Images/appels_and_oranges.jpg)
* _Äpfel mit Birnen vergleichen_
* _Comparer des choux et des carottes_
* _Paragonare cavoli e patate_ (compare cabbages and potatoes)

For a single 2D analysis (surface salinity in the Black Sea) on Intel Xeon CPU E5-2650.     
DIVA was compiled with the Intel Fortran Compiler.

|     | DIVA - Fortran | DIVAnd - julia |
|----|----------------|----------------|
| mesh             | triangular | structured | 
| deg. of freedom  |    236296 |  236317 |
| correlation length | 0.19    | 0.19 |
| CPU time | 43.8 s | 8.7 s |

* However, a triangular mesh is greatly more flexible than a structured mesh and has $C_1$ continuity
* The main advantage of `DIVAnd` is that it can work on more than just 2 dimensions (but the requirements of RAM memory increase also).

### On public servers (cloud)

`DIVAnd` has been made available in Virtual Research Environments (VRE) in the frame of European projects.     
The deployment is performed using a Docker container.  

For instance `DIVAnd` can used in projects such as:
- FAIR-EASE: https://fairease.eu/
- Blue-Cloud 2026: https://blue-cloud.org/ 

### Primary functions

* `DIVAndrun`: Implements the DIVA algorithm in N dimensions on a structured grid.
* `DIVAndgo`: Split the domain in overlapping subdomains and calls `DIVAndrun` on every subdomain (to reduce the memory consumption).
* `diva`: High-level function which selects the appropriate data.

## Installation

### Jupyter

Jupyter has to be installed in order to have a notebook interface.    
It can be installed and launched (in Julia) with the following commands

```julia
using Pkg
Pkg.add("IJulia")
using IJulia
notebook()
```

### Extensions [optional]

It is also recommended to install the following modules which allow, for example, to have the sections automatically numbered:
- https://github.com/ipython-contrib/jupyter_contrib_nbextensions
- https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator

## Other relevant repositories

### [EMODnet-Chemistry-GriddedMaps](https://github.com/gher-uliege/EMODnet-Chemistry-GriddedMaps)

This repository aims to store the notebooks and the instructions to produce the EMODnet Chemistry products (climatologies).

# Binder

Most notebooks need more resources that what is can currently available on Binder. The introduction notebooks (introduction to OI and variationa analysis) however work
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gher-uliege/Diva-Workshops/master?filepath=notebooks%2F1-Intro%2F04-OI-variational-analysis-introduction.ipynb).

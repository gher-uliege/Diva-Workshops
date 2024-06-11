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

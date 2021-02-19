[![Build Status](https://github.com/gher-ulg/Diva-Workshops/workflows/CI/badge.svg)](https://github.com/gher-ulg/Diva-Workshops/actions)
[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)

# DIVA Workshops and training

This page provides the [Jupyter](https://jupyter.org/) notebooks (examples and exercises) for the `DIVAnd` user workshops and training sessions organised in the frame of H2020 [SeaDataCloud](https://www.seadatanet.org/) project.     

[`Diva`](https://github.com/gher-ulg/DIVA) and [`DIVAnd`](https://github.com/gher-ulg/divand.jl) are software tools designed to generate gridded fields from in-situ observations.

## Objectives

* The [1st workshop](https://gher-ulg.github.io/Diva-Workshops/Previous/Diva-workshop-2018-Liege.html) (Liège, 3-6 April 2018) was focused on the creation of gridded products and climatologies using `DIVAnd`. The organizational details are available.

* Within the 2nd SeaDataCloud training course (19-26 June 2019), the objective is to introduce participants to the `Julia` language, the Jupyter notebooks and the new Virtual Research Environment.

* The [2nd workshop](https://gher-ulg.github.io/Diva-Workshops/2020/) (Bologna, 27-30 January 2020) was attended by beginners, intermediate and advanced users, and the goal was to help them create new products with `DIVAnd`.

## Recommendation for the products

A list of [recommendations](./tricks/climato_recommendation.md) for the preparation of products.

## Tips and tricks

### Export ODV to netCDF

[Instructions](./tricks/ODV_netCDF_export.md) and screen-shots detailing how to create a netCDF
from an ODV collection.

### Adding EDMO code and CDI to CORA data sets

[Instructions](./tricks/ODV_EDMO_CDI.md) and screen-shots to show how to add metadata to a CORA
dataset.

### Manipulation of a netCDF with nco

[Examples](./tricks/cutting_netcdf.md)

### Viewing netCDF file

[netCDF](./tricks/netCDV_viewing.md)

### Saving the attributes in a text file

This is useful when working on a machine with no internet connexion:      
[save_attributes_file.ipynb](notebooks/postprocessing/save_attributes_file.ipynb)

# Binder

Most notebooks need more resources that what is can currently available on Binder. The introduction notebooks (introduction to OI and variationa analysis) however work
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/gher-ulg/Diva-Workshops/master?filepath=notebooks%2F1-Intro%2F04-OI-variational-analysis-introduction.ipynb).

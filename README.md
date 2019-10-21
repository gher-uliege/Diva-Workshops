[![DOI](https://zenodo.org/badge/108153788.svg)](https://zenodo.org/badge/latestdoi/108153788)

# DIVA Workshops and training

This page provides the [Jupyter](https://jupyter.org/) notebooks (examples and exercises) for the `DIVAnd` user workshops and training sessions organised in the frame of H2020 [SeaDataCloud](https://www.seadatanet.org/) project.     

## Tools

[`Diva`](https://github.com/gher-ulg/DIVA) and [`DIVAnd`](https://github.com/gher-ulg/divand.jl) are software tools designed to generate gridded fields from in-situ observations.

## Objectives

* The 1st workshop (3-6 April 2018) was focused on the creation of gridded products and climatologies using `DIVAnd`. The organizational details are available https://gher-ulg.github.io/Diva-Workshops/.

* Within the 2nd SeaDataCloud training course (19-26 June 2019), the objective is to introduce participants to the `Julia` language, the Jupyter notebooks and the new Virtual Research Environment.

Following the 1st workshop, the notebooks have been updated, improved and corrected when necessary. New notebooks are developed based on the participants requirements.

## Recommendation for the products

A list of [recommendations](climato_recommendation.md) for the preparation of products.

## Export ODV to netCDF

[Instructions](ODV_netCDF_export.md) and screen-shots detailing how to create a netCDF
from an ODV collection.

## Adding EDMO code and CDI to CORA data sets

[Instructions](ODV_EDMO_CDI.md) and screen-shots to show how to add metadata to a CORA
dataset.

## Manipulation of a netCDF with nco

[Examples](cutting_netcdf.md)

## Viewing netCDF file

[netCDF](netCDV_viewing.md)

## Saving the attributes in a text file

This is useful when working on a machine with no internet connexion.
[save_attributes_file.ipynb](notebooks/postprocessing/save_attributes_file.ipynb)

---
title: 'DIVAnd training: producing climatologies with Jupyter notebooks'
tags:
  - oceanography
  - data analysis
  - spatial interpolation
  - Julia
  - Jupyter
authors:
  - name: Charles Troupin
    orcid: 0000-0002-0265-1021
    affiliation: 1
  - name: Alexander Barth
    orcid: 0000-0003-2952-5997
    affiliation: 1
  - name: Jean-Marie Beckers
    orcid: 0000-0002-7045-2470
    affiliation: 1
affiliations:
 - name: GHER, Freshwater and Oceanic sCiences Unit of reSearch, University of Liège, Belgium
   index: 1
date: 13 January 2025
bibliography: paper.bib

---


# Summary

The DIVA-workshops project consists of a set of Jupyter notebooks, focused on creation of gridded fields from in situ observations using the `DIVAnd`. `DIVAnd` is a software tool, written in Julia, which perform interpolation in an arbitrary number of dimensions. 

The notebooks address the different stages of the climatology generation: data reading and preparation, extraction of the topography and creation of a land-sea mask, setting of the spatial resolution and the time periods, estimation of the analysis parameters, analysis and creation of the metadata.

The target audience is wide as it includes: data analysts, who wish to create climatologies; physical oceanographers, who want to grid their observations for visualisation and potentially for quality control, programmers, who want to include the DIVAnd interpolation in a larger workflow involving other processing steps. 


# Statement of need

The gridding of in situ measurements is a common task in oceanography. It consists of the generation of one or several fields on a regular grid, using the information contained in a set of observations, generally sparsely distributed. The combination of such fields, produced at different depth levels and for different time periods, is often referred to as a climatology. 

This gridding problem is not new and many methods have been developed during the last decades.
<!---can you cite some other techniques? like OI?-->
<!---(Gandin, 1965; Bretherton et al., 1976)-->

`DIVA` stands for Data-Interpolating Variational Analysis [@troupin:2012] and is a analysis method based on the minimisation of a cost function. This cost function takes into account different constraint, typically the closeness to observations and the regularity (or smoothness) of the gridded field. DIVA, written in Fortran, was based on a finite-element solver and limited to two-dimensional applications. Climatologies were obtained by assembling 2D fields produced at specified depths and periods.

`DIVAnd` (DIVA in n dimensions) is based on the same mathematical idea (the minimisation of a cost function) but extended to an arbitrary number of dimensions, typically longitude, latitude, depth and time [@barth:2014]. The code was first rewritten so that it can run on MATLAB and GNU Octave. Its performances were further improved thanks to the transition to the Julia language [@bezanson:2017].   

Without reviewing the full development history of the gridding and interpolation algorithms, we underline two specific aspects that are adequately addressed by DIVAnd (and DIVA) with respect to existing techniques:
1. The management of large datasets: the computation time is almost independent of the number of observations, making it possible to perform gridding with millions of data points.
2. The consideration of natural boundaries (coastlines, bottom topography) during the interpolation, hence avoiding the artificial mixing of water masses that are geographically close but separated by a physical obstacle.

The [`DIVAnd`](https://github.com/gher-uliege/DIVAnd.jl/) code is published on GitHub along with its documentation and examples, and the underlying theory has been published in @barth:2014. However, in order to ensure that users are able to create their own climatologies, with a rather recent programming language, additional teaching resources were necessary. This is the main motivation behind the creation and the maintenance of the [Diva-Workshops](https://github.com/gher-uliege/Diva-Workshops) repository.

# The DIVAnd learning module

## The story 

The first DIVA workshop was organised in Liège, Belgium, in 2006, in the frame of the European project [Seadatanet](https://www.seadatanet.org/). The goal was to teach users how to create climatologies by applying the DIVA (the two-dimensional, Fortran version) on their own dataset. Those training sessions were organised yearly until 2016 and allowed the creation of regional climatologies, published in the frame of European initiatives (SeaDataNet, EMODnet).

Taking advantage of the Jupyter interface [@kluyver:2016] and transition to Julia for the new version of DIVAnd, a set of notebooks was created as the main material for the user training. The first `DIVAnd` workshop took place in April 2018 in Liège. Since then, other training events were organised, while the training material is regularly used as the basis for the creation of gridded products for EMODnet Chemistry [@giorgetti:2018]. The choice of the Jupyter notebooks format was motivated by the interactivity and the step-by-step, documented approach. 

The participant feedback is particularly valued, considering that it guide the development of new functionalities in the `DIVAnd` source code, but also the creation of new notebooks describing specific workflows (for instance the consideration of geostrophy) or the use of particular functions (for instance the use of an advection constrain in the interpolation). 

## Goal of the module

The goal of the training material module is twofold: 
1. provide the users with a basic knowledge of Julia, meaning they are capable of reading the code presented in the notebooks, but also install new modules, write basic functions for processing or create basic plots. 
2. endure that the users to able to create their own products (i.e. climatologies) by combining their own datasets with those from other sources (for instance the World Ocean Database) and setting the analysis parameters according to their region of interest.

Julia syntax bear similarities with other widespread languages, for instance MATLAB, yet some specificities have to explained to make sure users can make the most of it. 

## Instructional design

The notebooks have been organised by sub-folders according to their objectives:
1. Introduction: brief introduction to the Julia language and to the Jupyter notebooks, how to deal with netCDF files (reading and writing) and how to generate figures (maps, sections, ...). 
2. Preprocessing: preparation of the input required by `DIVAnd` (grid, time periods, bathymetry, observations) and estimation of the main analysis parameters (correlation length and noise-to-signal ratio). Code fragments dealing with various file formats (CSV, netCDF, TIFF, ...) are also provided to help users work with the most frequent types of data.
3. Analysis: creating of gridded fields with DIVAnd, influence of the analysis parameters, and interpolation with different coordinate systems.
4. Advanced topics: this folder contains less frequently used notebooks, dealing with the generation of density maps, relative correlation length, background fields, advection constraints.

Since the notebooks require input data files (mainly bathymetry and observations) to be executed, we ensure those files are available from a public file server and downloaded locally whenever necessary. 

Following our experience with users, for the creation of plots, the Makie module [@danisch:2021] (along with `GeoMakie` for the maps) was selected to replce `PyPlot` (along with `Cartopy` [@Cartopy:2010] for the maps), which is based on the Python Matplotlib module [@hunter:2007]. Indeed, the import of PyPlot in the notebooks often generated errors on the user's machine, with sensitivity to the operating system and the pre-existing Python installation(s).

## Users and applications

The user community mainly consists of scientists, data analysists and experts. This diversity implies that the content has to be taylored and sufficient to ensure users without any prior knowledge of Julia and Jupyter are able to run and modify the notebooks. 

Among the applications we can mention de EMODnet products [@Webb:2025]. 
Other recent applications include the creation of climatologies and gridded fields for sea surface height [@Doglioni:2023]
temperature and salinity [@Shahzadi:2021] and nutrients [@Belgacem:2021].


# Acknowledgements

We acknowledge contributions from European Union's Horizon 2020 SeaDataCloud project (grant agreement No. 730960), from Horizon Europe research and innnovation FAIR-EASE project (grant agreement No. 101058785, DOI: [10.3030/101058785](https://doi.org/10.3030/101058785)), Blue-Cloud 2026 (grant agreement No. 101094227, DOI: [10.3030/101094227](https://doi.org/10.3030/101094227)) and IRISCC (grant agreement No. 101131261, DOI: [10.3030/101131261](https://doi.org/10.3030/101131261)).

We wish to acknowledge the participants to the different editions of the DIVA workshops, since their feedback was essential to build and improve the content of the training sessions.

# References

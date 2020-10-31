# **<div align="center">PiPWV</div>**

This repository contains the basic setup for the **PiPWV** project, written in Julia.  We aim to:
   (1) compare different values of Π calculated from different types of datsets
   (2) create an automated creation of dataset Π based on ERA5 reanalysis data using Julia and `CDSAPI.jl`

**Created/Mantained By:** Nathanael Wong (nathanaelwong@fas.harvard.edu)\
**Other Contributors:** Lujia Feng (lfeng@ntu.edu.sg)

> Introductory Text Here.

## Progress

* [x] Data Downloads
   * [x] Downloaded ERA5 Raw Data
   * [x] Downloaded ERA-Interim Raw Data

* [x] Calculation of Tm and `Π`
   * [x] **RE5:** Reanalysis - ERA5 - Vertical
   * [x] **REI:** Reanalysis - ERA-Interim - Vertical
   * [x] **REP:** Reanalysis - ERA5 - Pressure
   * [x] **RGA:** Reanalysis - GGOS Atmosphere [Bohm et al., 2013] (calculated from ERA-Interim)
   * [x] **EBB:** Empirical - Bevis et al. [1992] approximation - Bevis et al. [1992] Coefficients
   * [x] **EBM:** Empirical - Bevis et al. [1992] approximation - Manandhar et al. [2017] Coefficients
   * [x] **EMN:** Empirical - Manandhar et al. [2017]
   * [x] **EG2:** Empirical - GPT2w Model [Bohm et al., 2015] derived from GGOS Atmosphere

* [x] Analysis/Comparison between Datasets
   * [x] Analysis of diurnal and seasonal variability for **RE5**
   * [x] Comparison of **RE5** to **REI** and see if **RE5** is vastly different from **REI** and how
   * [x] Comparison to **RE5** to **REP** and see if **REP** is close to **RE5** so that in the future can use **REP** and save computational power and data downloading time
   * [x] Comparison of **REI** to **RGA** (since RGA is taken from ERA-Interim, so comparing a direct ERA-Interim calculation makes more sense)
   * [x] Compare **RE5** to **EBB** and **EBM** to see if Bevis et al. [1992] methodology is a globally valid approximation
   * [x] See if empirical models **EG2** and **EMN** are close approximations or if it would be better to just use a single gridded `Π` dataset

* [ ] `Π` Dataset creation
   * [ ] Write functions (modify from `ClimateERA`) to download daily meteorological data
   * [ ] Calculate `Π` daily and append to relevant NetCDF file using `NCDatasets`

## Installation

To (locally) reproduce this project, do the following:

0. Download this code base. Notice that raw data are typically not included in the
   git-history and may need to be downloaded independently.
1. Open a Julia console and do:
   ```
   julia> ] activate .
    Activating environment at `~/Projects/PiPWV/Project.toml`

   (PiPWV) pkg> instantiate
   ```

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box.

## Other Acknowledgements
> Project Repository Template generated using [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl) created by George Datseris.
> Work from this project was funded by the [Earth Observatory of Singapore](https://earthobservatory.sg/).

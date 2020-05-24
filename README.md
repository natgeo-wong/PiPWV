# **<div align="center">PiPWV</div>**

This repository contains the basic setup for the **PiPWV** project, used to calculate a global gridded dataset of water-vapour-weighted column-mean temperature, and `Π`, which is the conversion factor between zenith-wet-delay (ZWD) in GPS datasets, and precipitable water vapour (PWV).

**Created/Mantained By:** Nathanael Wong (nathanaelwong@fas.harvard.edu)\
**Other Contributors:** Lujia Feng (lfeng@ntu.edu.sg)

> Introductory Text Here.

## Current Status

**Data Downloads**
* [x] Downloaded ERA5 Raw Data
* [ ] Downloaded ERA-Interim Raw Data

**Calculation of Tm and `Π`**
* [x] **RE5:** Reanalysis - ERA5 - Vertical
* [ ] **REI:** Reanalysis - ERA-Interim - Vertical
* [x] **REP:** Reanalysis - ERA5 - Pressure
* [x] **RGA:** Reanalysis - GGOS Atmosphere [Bohm et al., 2013] (calculated from ERA-Interim)
* [x] **EBB:** Empirical - Bevis et al. [1992] approximation - Bevis et al. [1992] Coefficients
* [x] **EBM:** Empirical - Bevis et al. [1992] approximation - Manandhar et al. [2017] Coefficients
* [x] **EMN:** Empirical - Manandhar et al. [2017]
* [x] **EG2:** Empirical - GPT2w Model [Bohm et al., 2015] derived from GGOS Atmosphere

**Analysis/Comparison between Datasets**

* [ ] Analysis of diurnal and seasonal variability for **RE5**
* [ ] Comparison of **RE5** to **REI** and see if **RE5** is vastly different from **REI** and how
* [ ] Comparison to **RE5** to **REP** and see if **REP** is close to **RE5** so that in the future can use **REP** and save computational power and data downloading time
* [ ] Comparison of **REI** to **RGA** (since RGA is taken from ERA-Interim, so comparing a direct ERA-Interim calculation makes more sense)
* [ ] Compare **RE5** to **EBB** and **EBM** to see if Bevis et al. [1992] methodology is a globally valid approximation
* [ ] See if empirical models **EG2** and **EMN** are close approximations or if it would be better to just use a single gridded `Π` dataset

**`Π` Dataset creation**
* [ ] Write functions (modify from `ClimateERA`) to download daily meteorological data
* [ ] Calculate `Π` daily and append to relevant NetCDF file using `NCDatasets`

## Project Setup

In order to obtain the relevant data, please follow the instructions listed below:

### 1) Required Julia Dependencies

The entire codebase is written in Julia.  If the data files are downloaded, you should be able to produce my results in their entirety.  The following are the most important Julia packages that were used in this project:
* ECWMF Data Handling: `ClimateERA.jl`
* NetCDF Data Handling: `NCDatasets.jl`
* Numerical Methods: `NumericalIntegration.jl`, `Dierckx.jl`

In order to reproduce the results, first you have to clone the repository, and instantiate the project environment in the Julia REPL in order to install the required packages:
```
git clone https://github.com/natgeo-wong/PiPWV.git
] activate .
instantiate
```

### 2) ECMWF Reanalysis Data

Text

### 3) GGOS Atmospheric Tm Data

Text

### 4) GPT2w Tm Data

Text

## **Other Acknowledgements**
> Project Repository Template generated using [DrWatson.jl](https://github.com/JuliaDynamics/DrWatson.jl) created by George Datseris.
> Work from this project was funded by the [Earth Observatory of Singapore](https://earthobservatory.sg/).

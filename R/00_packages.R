# 00_packages.R
# Load all packages used in the analysis.
# Run renv::restore() once before first use to install pinned versions.

library(ctmm)       # continuous-time movement modelling, AKDE (Calabrese et al. 2016)
library(amt)        # MCP estimation and step-length calculations (Signer et al. 2019)
library(sf)         # spatial data handling
library(ggplot2)    # figures
library(maptiles)   # basemap tiles
library(tidyterra)  # terra/ggplot2 bridge for raster tiles
library(dplyr)      # data wrangling
library(tidyr)      # reshaping
library(lubridate)  # date/time
library(readr)      # CSV import
library(units)      # unit-aware quantities (area)
library(patchwork)  # figure composition

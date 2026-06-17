# GPS tracking and home-range ecology of Fuegian Snipe (*Gallinago stricklandii*)

**Medrano et al. (in prep)**

---

## Overview

This repository contains the R code used to process GPS tracking data, estimate home ranges, and produce the figures and tables for:

> Medrano, F., Raimilla, V., Contardo, N., Gallardo, B., Gutiérrez, P., Melgarejo, M., Muñoz, B., Quintanilla, E., Sandvig, E. M., Eberhart-Hertel, L., and Kempenaers, B. GPS tracking provides evidence of year-round residency in Fuegian Snipe (*Gallinago stricklandii*) at the northern edge of their Patagonian breeding range. *In preparation.*

Two adult Fuegian Snipe were captured and fitted with PinPoint 120 GPS-Argos transmitters (~6 g; ~2.6% body mass) at Parque La Tapera, Aysén Region, Chile (~48°S), in October 2024. Both individuals were tracked through July 2025 (264–424 days). Home ranges were estimated using autocorrelated kernel density estimation (AKDE; Fleming et al. 2015) implemented in the `ctmm` package (Calabrese et al. 2016). MCPs and step lengths were calculated with the `amt` package (Signer et al. 2019).

---

## Data

Raw GPS relocations are archived in the **Movebank Data Repository**:

> Movebank Study ID: **5109989622**  
> URL: <https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study5109989622>

Data are not duplicated in this repository. Export the study as CSV from Movebank and place it at `data/movebank_5109989622.csv` before running the pipeline.

---

## Repo structure

```
fuegian-snipe-gps/
├── README.md
├── .gitignore
├── renv.lock                    # package snapshot (generate with renv::snapshot())
├── data/
│   └── data_dictionary.md       # column descriptions for the Movebank export
├── R/
│   ├── 00_packages.R            # library calls
│   ├── 01_load_clean.R          # import, filter, format; builds dat and telem
│   ├── 02_ctmm_fit.R            # variogram + ctmm.select; full tracks and
│   │                            #   two sub-periods of individual 266503
│   ├── 03_akde.R                # AKDE UDs (50% + 95%) with 95% CIs
│   ├── 04_mcp.R                 # 95% + 100% MCPs; step lengths via amt::steps
│   └── 05_figures.R             # Figure 2 (map + AKDE isopleths)
├── analysis/
│   └── main_analysis.R          # master runner: sources 00–05 in order
└── outputs/
    ├── figures/                 # fig2_map.pdf / .png
    └── tables/                  # akde_areas.csv, mcp_areas.csv, step_lengths.csv
```

---

## Reproducing the analysis

### Requirements

- R ≥ 4.3
- [`renv`](https://rstudio.github.io/renv/) for package management

### Steps

```r
# 1. Clone the repo and open it as an RStudio project
# 2. Restore the package library
renv::restore()

# 3. Export Movebank study 5109989622 as CSV and place at data/movebank_5109989622.csv

# 4. Run the full pipeline
source("analysis/main_analysis.R")
```

Figures are written to `outputs/figures/` and tables to `outputs/tables/`.

---

## Key dependencies

| Package | Role | Reference |
|---------|------|-----------|
| `ctmm` | Continuous-time movement modelling, AKDE | Calabrese et al. 2016; Fleming et al. 2015 |
| `amt` | MCP estimation (`hr_mcp`), step lengths (`steps`) | Signer et al. 2019 |
| `sf` | Spatial data handling | — |
| `ggplot2` | Figures | — |
| `maptiles` | Basemap tiles | — |
| `dplyr` / `lubridate` / `readr` | Data wrangling | — |

Full version list in `renv.lock`.

---

## License

Code: [MIT License](LICENSE)  
Data: see Movebank study 5109989622 for terms of use.

---

## Contact

Erik M. Sandvig — eriksandvig@redobservadores.cl - Red de Observadores de Aves y Vida Silvestre de Chile (ROC)
Fernando Medrano — fernandomedrano@redobservadores.cl - Red de Observadores de Aves y Vida Silvestre de Chile (ROC) 

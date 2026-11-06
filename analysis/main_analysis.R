# main_analysis.R
# Full pipeline. Before running: renv::restore() and place the Movebank export
# (study 5109989622) at data/movebank_5109989622.csv.

source("R/00_packages.R")
source("R/01_load_clean.R")   # dat, telem
source("R/02_ctmm_fit.R")     # variograms (Fig. S1), model selection (pHREML, AICc)
source("R/03_akde.R")         # AKDEc 50% / 95% UDs, tau_p, N_area
source("R/04_mcp.R")          # MCP95 / MCP100, step lengths
source("R/05_figures.R")      # Fig. 2

# main_analysis.R
# Master script — runs the full analysis pipeline in order.
# Before running: place Movebank CSV export in data/ and call renv::restore().

source("R/00_packages.R")
source("R/01_load_clean.R")   # imports data; creates dat, telem
source("R/02_ctmm_fit.R")     # fits ctmm models; creates fits, fits_266503,
                               #   t1_start/end, t2_start/end, subset_tel()
source("R/03_akde.R")         # AKDE home ranges; creates akdes, akdes_266503
source("R/04_mcp.R")          # MCPs (95% + 100%) and step lengths via amt
source("R/05_figures.R")      # Figure 2 (map + isopleths)

cat("\nPipeline complete.\n")
cat("Tables : outputs/tables/\n")
cat("Figures: outputs/figures/\n")

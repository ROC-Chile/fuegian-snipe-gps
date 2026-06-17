# 03_akde.R
# Estimate autocorrelated kernel density utilization distributions (AKDE).
# Reports 50% (core) and 95% UD area estimates with 95% confidence intervals.
#
# Also estimates separate AKDEs for the two sub-periods of individual 266503,
# corresponding to the discrete shift to a secondary activity centre (Mar 2025).
#
# Output:
#   akdes          — named list of UD objects (full tracks)
#   akdes_266503   — named list of UD objects for 266503 sub-periods
#   ud_table       — data frame of area estimates (all individuals and periods)

# --- Full-track AKDEs ---
akdes <- mapply(akde, object = telem, CTMM = fits, SIMPLIFY = FALSE)

# --- Sub-period AKDEs for 266503 ---
tel_p1 <- subset_tel(telem[["266503"]], t1_start, t1_end)
tel_p2 <- subset_tel(telem[["266503"]], t2_start, t2_end)

akdes_266503 <- list(
  period1 = akde(tel_p1, fits_266503$period1),
  period2 = akde(tel_p2, fits_266503$period2)
)

# --- Extract area estimates (km²) ---
extract_ud_areas <- function(ud, id, period = "full") {
  s <- summary(ud, units = FALSE)$CI   # rows = isopleths, cols = low / est / high
  data.frame(
    individual    = id,
    period        = period,
    isopleth      = c("50%", "95%"),
    area_km2_low  = s[, 1] / 1e6,
    area_km2_est  = s[, 2] / 1e6,
    area_km2_high = s[, 3] / 1e6
  )
}

ud_table <- bind_rows(
  lapply(names(akdes), function(id) extract_ud_areas(akdes[[id]], id)),
  extract_ud_areas(akdes_266503$period1, "266503", "Oct-Mar 2024/25"),
  extract_ud_areas(akdes_266503$period2, "266503", "Mar-Jun 2025")
)

cat("\nAKDE utilization distribution areas (km²):\n")
print(ud_table)
write_csv(ud_table, "outputs/tables/akde_areas.csv")

# 03_akde.R
# Area-corrected autocorrelated KDE (AKDEc; debias = TRUE) conditional on the
# selected model. Reports 50% and 95% UD areas with 95% CIs, plus the
# positional autocorrelation timescale (tau_p) and the effective sample size
# for area (N_area ~ T / tau_p), so the precision of each estimate is explicit.
#
# Output:
#   akdes     - named list of UD objects
#   ud_table  - outputs/tables/akde_areas.csv

akdes <- mapply(function(tel, fit) akde(tel, fit, debias = TRUE),
                telem, fits, SIMPLIFY = FALSE)

ci_row <- function(ci_mat, pattern) {
  ci_mat[grep(pattern, rownames(ci_mat)), , drop = FALSE][1, ]
}

ud_table <- bind_rows(lapply(names(akdes), function(id) {
  fit_ci <- summary(fits[[id]], units = FALSE)$CI
  tau_p  <- if (any(grepl("position", rownames(fit_ci)))) {
    ci_row(fit_ci, "position") / 86400            # seconds -> days
  } else rep(NA_real_, 3)                          # IID: no tau_p

  bind_rows(lapply(c(0.50, 0.95), function(lvl) {
    s  <- summary(akdes[[id]], level.UD = lvl, units = FALSE)
    ci <- ci_row(s$CI, "area") / 1e4               # m^2 -> ha
    tibble(
      individual   = id,
      n_fixes      = nrow(telem[[id]]),
      model        = summary(fits[[id]])$name,
      tau_p_days   = tau_p[2],
      tau_p_low    = tau_p[1],
      tau_p_high   = tau_p[3],
      N_area       = unname(s$DOF["area"]),
      isopleth     = paste0(lvl * 100, "%"),
      area_ha_low  = ci[1],
      area_ha_est  = ci[2],
      area_ha_high = ci[3]
    )
  }))
}))

print(ud_table)
write_csv(ud_table, "outputs/tables/akde_areas.csv")

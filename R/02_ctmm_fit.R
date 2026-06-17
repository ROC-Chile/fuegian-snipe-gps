# 02_ctmm_fit.R
# Fit continuous-time movement models to each individual, and to the two
# sub-periods of individual 266503 (before and after the March 2025 shift).
#
# Candidate models compared by AICc: IID, OU, OUF, OUanisotropic.
#
# Output:
#   fits        — named list of best-fit ctmm models (full tracks)
#   fits_266503 — named list of best-fit models for 266503 sub-periods

set.seed(42)

# --- Full-track model selection ---
fits <- lapply(telem, function(tel) {
  guess <- ctmm.guess(tel, interactive = FALSE)
  ctmm.select(tel, guess, verbose = FALSE)
})
names(fits) <- names(telem)

cat("Best-fit models (full tracks):\n")
for (id in names(fits)) {
  cat(" ", id, "->", summary(fits[[id]])$name, "\n")
}

# --- Sub-period fits for individual 266503 ---
# Period 1: 14 Oct 2024 – 15 Mar 2025 (pre-shift)
# Period 2: 23 Mar 2025 – 3 Jun 2025  (secondary activity centre)

tel_266503 <- telem[["266503"]]

t1_start <- as.POSIXct("2024-10-14", tz = "UTC")
t1_end   <- as.POSIXct("2025-03-15", tz = "UTC")
t2_start <- as.POSIXct("2025-03-23", tz = "UTC")
t2_end   <- as.POSIXct("2025-06-03", tz = "UTC")

# Subset telemetry by period
subset_tel <- function(tel, from, to) {
  idx <- tel$t >= as.numeric(from) & tel$t <= as.numeric(to)
  tel[idx, ]
}

tel_p1 <- subset_tel(tel_266503, t1_start, t1_end)
tel_p2 <- subset_tel(tel_266503, t2_start, t2_end)

fit_period <- function(tel) {
  guess <- ctmm.guess(tel, interactive = FALSE)
  ctmm.select(tel, guess, verbose = FALSE)
}

fits_266503 <- list(
  period1 = fit_period(tel_p1),
  period2 = fit_period(tel_p2)
)

cat("\nBest-fit models for 266503 sub-periods:\n")
cat("  Period 1 (Oct–Mar):", summary(fits_266503$period1)$name, "\n")
cat("  Period 2 (Mar–Jun):", summary(fits_266503$period2)$name, "\n")

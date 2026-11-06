# 02_ctmm_fit.R
# (1) Assess range residency from the empirical variogram of each individual.
# (2) Select a continuous-time movement model by AICc among IID (null; AKDE
#     reduces to conventional KDE), OU (positional autocorrelation, tau_p),
#     and OUF/OUf (positional + velocity autocorrelation, tau_v), in isotropic
#     and anisotropic forms, fitted by perturbative hybrid REML (pHREML).
#
# Output:
#   vgs   - named list of empirical variograms
#   fits  - named list of selected ctmm models
#   outputs/figures/figS1_variograms.pdf / .png

set.seed(42)

# --- (1) Empirical variograms ---
vgs <- lapply(telem, variogram)

# --- (2) Model selection ---
fits <- lapply(telem, function(tel) {
  guess <- ctmm.guess(tel, interactive = FALSE)
  ctmm.select(tel, guess, method = "pHREML", IC = "AICc", verbose = FALSE)
})

cat("Selected models:\n")
for (id in names(fits)) cat(" ", id, "->", summary(fits[[id]])$name, "\n")

# --- Fig. S1: variograms with selected model overlaid ---
# Left panel per bird: full lag range (asymptote = range residency).
plot_vg <- function() {
  op <- par(mfrow = c(1, length(vgs)), mar = c(4.5, 4.5, 2, 1))
  for (id in names(vgs)) {
    plot(vgs[[id]], CTMM = fits[[id]], fraction = 1, level = c(0.5, 0.95),
         main = id)
  }
  par(op)
}
pdf("outputs/figures/figS1_variograms.pdf", width = 8, height = 4)
plot_vg(); dev.off()
png("outputs/figures/figS1_variograms.png", width = 8, height = 4,
    units = "in", res = 300)
plot_vg(); dev.off()

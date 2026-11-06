# 01_load_clean.R
# Import Movebank CSV export (study 5109989622) and apply standard filters.
#
# Output:
#   dat    - tibble of GPS-only fixes (Doppler-derived Argos fixes discarded)
#   telem  - named list of ctmm telemetry objects (one per individual)

movebank_file <- "data/movebank_5109989622.csv"

raw <- read_csv(movebank_file, show_col_types = FALSE) |>
  rename_with(~ gsub("[.-]", "_", tolower(.)))

# Remove Movebank-flagged outliers, if the column is present in the export
if ("manually_marked_outlier" %in% names(raw)) {
  raw <- raw |>
    filter(is.na(manually_marked_outlier) | !as.logical(manually_marked_outlier))
}

# Discard Doppler-derived Argos fixes; retain GPS fixes only.
# Movebank exports sensor type in lower case ("gps", "argos-doppler-shift").
dat <- raw |>
  filter(tolower(sensor_type) == "gps",
         !is.na(location_long), !is.na(location_lat)) |>
  mutate(timestamp  = ymd_hms(timestamp, tz = "UTC"),
         individual = as.character(individual_local_identifier)) |>
  arrange(individual, timestamp)

cat("GPS fixes per individual:\n")
print(table(dat$individual))

# ctmm telemetry objects (ctmm chooses an equal-area projection)
telem <- as.telemetry(as.data.frame(dat), timezone = "UTC")
if (inherits(telem, "telemetry")) telem <- list(telem)   # single-individual safety
names(telem) <- vapply(telem, function(x) x@info$identity, character(1))

# 01_load_clean.R
# Import Movebank CSV export (study 5109989622) and apply standard filters.
#
# Output:
#   dat      — tibble of GPS-only fixes (Doppler-derived Argos fixes discarded)
#   telem    — named list of ctmm telemetry objects (one per individual)

movebank_file <- "data/movebank_5109989622.csv"

raw <- read_csv(movebank_file, show_col_types = FALSE)

# Standardise column names to snake_case
raw <- raw |>
  rename_with(~ gsub("\\.", "_", tolower(.)))

# Remove Movebank-flagged outliers
raw <- raw |>
  filter(is.na(manually_marked_outlier) | manually_marked_outlier == FALSE)

# Discard Doppler-derived Argos fixes; retain GPS fixes only
dat <- raw |>
  filter(sensor_type == "GPS") |>
  filter(!is.na(location_long), !is.na(location_lat)) |>
  mutate(
    timestamp  = ymd_hms(timestamp),
    individual = individual_local_identifier
  ) |>
  arrange(individual, timestamp)

cat("Individuals:", paste(unique(dat$individual), collapse = ", "), "\n")
cat("GPS fixes per individual:\n")
print(table(dat$individual))
cat("Date range:", format(range(dat$timestamp)), "\n")

# Convert to ctmm telemetry objects
telem <- as.telemetry(dat,
                      timeformat = "%Y-%m-%d %H:%M:%S",
                      timezone   = "UTC",
                      projection = NULL)   # ctmm selects an equal-area projection

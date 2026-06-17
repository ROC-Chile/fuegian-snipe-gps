# 04_mcp.R
# Calculate 95% and 100% minimum convex polygons (MCPs) using the amt package
# (Signer et al. 2019), and compute step lengths between consecutive fixes.
#
# Output:
#   mcp_table   — data frame of MCP areas (km²) per individual and period
#   step_table  — data frame of step-length summary stats per individual

# --- Build amt tracks ---
# amt requires a track_xyt object; use the GPS-only data in dat

make_track <- function(df) {
  df |>
    make_track(.x = location_long, .y = location_lat,
               .t = timestamp, crs = 4326) |>
    transform_coords(crs_to = 32719)  # UTM zone 19S (covers Aysén)
}

tracks <- dat |>
  group_by(individual) |>
  group_map(~ make_track(.x), .keep = TRUE)
names(tracks) <- unique(dat$individual)

# --- MCPs ---
mcp_row <- function(trk, id, period = "full") {
  m95  <- hr_mcp(trk, levels = 0.95)
  m100 <- hr_mcp(trk, levels = 1.00)
  data.frame(
    individual  = id,
    period      = period,
    mcp95_km2   = as.numeric(hr_area(m95,  units = FALSE)) / 1e6,
    mcp100_km2  = as.numeric(hr_area(m100, units = FALSE)) / 1e6
  )
}

# Full-track MCPs
mcp_list <- lapply(names(tracks), function(id) mcp_row(tracks[[id]], id))

# Sub-period MCPs for 266503
trk_266503 <- tracks[["266503"]]
trk_p1 <- trk_266503 |> filter(t_ >= t1_start & t_ <= t1_end)
trk_p2 <- trk_266503 |> filter(t_ >= t2_start & t_ <= t2_end)

mcp_list <- c(
  mcp_list,
  list(mcp_row(trk_p1, "266503", "Oct-Mar 2024/25")),
  list(mcp_row(trk_p2, "266503", "Mar-Jun 2025"))
)

mcp_table <- bind_rows(mcp_list)
cat("\nMCP areas (km²):\n")
print(mcp_table)
write_csv(mcp_table, "outputs/tables/mcp_areas.csv")

# --- Step lengths via amt::steps ---
step_summary <- lapply(names(tracks), function(id) {
  sl <- tracks[[id]] |>
    steps() |>
    pull(sl_)   # step length in metres (UTM projection)
  data.frame(
    individual       = id,
    mean_step_m      = mean(sl,   na.rm = TRUE),
    median_step_m    = median(sl, na.rm = TRUE),
    max_step_m       = max(sl,    na.rm = TRUE)
  )
}) |> bind_rows()

cat("\nStep lengths (m, ~8-day fix interval):\n")
print(step_summary)
write_csv(step_summary, "outputs/tables/step_lengths.csv")

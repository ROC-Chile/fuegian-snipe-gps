# 04_mcp.R
# 95% and 100% MCPs and step lengths between consecutive fixes (amt).
#
# Output:
#   outputs/tables/mcp_areas.csv
#   outputs/tables/step_lengths.csv

build_track <- function(df) {
  amt::make_track(df, .x = location_long, .y = location_lat, .t = timestamp,
                  crs = 4326) |>
    amt::transform_coords(crs_to = 32718)   # UTM 18S (La Tapera, ~73.6 W)
}

tracks <- split(dat, dat$individual) |> lapply(build_track)

mcp_table <- bind_rows(lapply(names(tracks), function(id) {
  m <- hr_mcp(tracks[[id]], levels = c(0.95, 1.00))
  hr_area(m) |>
    transmute(individual = id,
              level      = paste0("MCP", level * 100),
              area_ha    = as.numeric(area) / 1e4)
}))
print(mcp_table)
write_csv(mcp_table, "outputs/tables/mcp_areas.csv")

step_table <- bind_rows(lapply(names(tracks), function(id) {
  sl <- steps(tracks[[id]])$sl_                     # metres
  tibble(individual    = id,
         mean_step_m   = mean(sl,   na.rm = TRUE),
         median_step_m = median(sl, na.rm = TRUE),
         max_step_m    = max(sl,    na.rm = TRUE))
}))
print(step_table)
write_csv(step_table, "outputs/tables/step_lengths.csv")

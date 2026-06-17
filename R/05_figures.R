# 05_figures.R
# Produce manuscript figures.
#
# Figure 1 (not coded here): field photo of tagged bird — see manuscript.
#
# Figure 2: GPS fixes and AKDE home-range isopleths for both individuals.
#   50% UD = solid contour; 95% UD = dotted contour (as described in MS).

# Colour palette — one colour per individual
ind_cols <- c("266503" = "#2166AC", "266504" = "#D6604D")

# --- Convert AKDE UDs to sf polygons ---
ud_to_sf <- function(ud, level, id, crs_out = 4326) {
  pol <- as.sf(ud, level = level)   # ctmm >= 0.6 exports sf directly
  pol |>
    st_transform(crs_out) |>
    mutate(individual = id, isopleth = paste0(level * 100, "%"))
}

akde_sf <- bind_rows(lapply(names(akdes), function(id) {
  bind_rows(
    ud_to_sf(akdes[[id]], 0.50, id),
    ud_to_sf(akdes[[id]], 0.95, id)
  )
}))

# --- Basemap tiles ---
bbox_wm <- akde_sf |>
  st_transform(3857) |>
  st_bbox() |>
  st_as_sfc() |>
  st_buffer(3000) |>
  st_bbox()

tiles <- get_tiles(bbox_wm, provider = "CartoDB.Positron", zoom = 13, crop = TRUE)

# --- GPS fixes as sf ---
fixes_sf <- st_as_sf(dat, coords = c("location_long", "location_lat"), crs = 4326)

# --- Figure 2 ---
fig2 <- ggplot() +
  tidyterra::geom_spatraster_rgb(data = tiles) +
  # 95% UD (dotted contour, per MS)
  geom_sf(data  = st_transform(akde_sf |> filter(isopleth == "95%"), 3857),
          aes(colour = individual),
          fill  = NA, linetype = "dotted", linewidth = 0.7) +
  # 50% UD (solid contour, per MS)
  geom_sf(data  = st_transform(akde_sf |> filter(isopleth == "50%"), 3857),
          aes(colour = individual),
          fill  = NA, linetype = "solid", linewidth = 0.9) +
  # GPS fixes
  geom_sf(data  = st_transform(fixes_sf, 3857),
          aes(colour = individual), size = 1.5, alpha = 0.8) +
  scale_colour_manual(values = ind_cols, name = "Individual") +
  labs(
    title   = expression("PinPoint 120 Argos/GPS fixes — " *
                           italic("Gallinago stricklandii") *
                           " at Parque La Tapera"),
    subtitle = "October 2024 – December 2025",
    caption  = "Solid line: 50% UD; dotted line: 95% UD"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave("outputs/figures/fig2_map.pdf", fig2, width = 16, height = 14, units = "cm")
ggsave("outputs/figures/fig2_map.png", fig2, width = 16, height = 14, units = "cm", dpi = 300)
cat("Figure 2 saved.\n")

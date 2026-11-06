# 05_figures.R
# Figure 2: GPS fixes with AKDEc 50% (solid) and 95% (dotted) UD contours.
# (Fig. S1, the variograms, is produced in 02_ctmm_fit.R.)

ind_cols <- c("266503" = "#2166AC", "266504" = "#D6604D")

# Point-estimate UD contour as sf (level.UD = isopleth; drop CI polygons)
ud_to_sf <- function(ud, lvl, id) {
  as.sf(ud, level.UD = lvl) |>
    filter(grepl("est", name)) |>
    st_transform(4326) |>
    mutate(individual = id, isopleth = paste0(lvl * 100, "%"))
}

akde_sf <- bind_rows(lapply(names(akdes), function(id) {
  bind_rows(ud_to_sf(akdes[[id]], 0.50, id), ud_to_sf(akdes[[id]], 0.95, id))
}))

fixes_sf <- st_as_sf(dat, coords = c("location_long", "location_lat"), crs = 4326)

bbox_wm <- akde_sf |> st_transform(3857) |> st_bbox() |> st_as_sfc() |>
  st_buffer(3000) |> st_bbox()
tiles <- get_tiles(bbox_wm, provider = "CartoDB.Positron", zoom = 13, crop = TRUE)

fig2 <- ggplot() +
  geom_spatraster_rgb(data = tiles) +
  geom_sf(data = st_transform(filter(akde_sf, isopleth == "95%"), 3857),
          aes(colour = individual), fill = NA, linetype = "dotted", linewidth = 0.7) +
  geom_sf(data = st_transform(filter(akde_sf, isopleth == "50%"), 3857),
          aes(colour = individual), fill = NA, linetype = "solid", linewidth = 0.9) +
  geom_sf(data = st_transform(fixes_sf, 3857),
          aes(colour = individual), size = 1.5, alpha = 0.8) +
  scale_colour_manual(values = ind_cols, name = "Individual") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

ggsave("outputs/figures/fig2_map.pdf", fig2, width = 16, height = 14, units = "cm")
ggsave("outputs/figures/fig2_map.png", fig2, width = 16, height = 14, units = "cm", dpi = 300)

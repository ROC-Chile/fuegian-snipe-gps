# Data dictionary — Movebank study 5109989622

Raw data are exported from Movebank and placed in `data/movebank_5109989622.csv`.
This file is not version-controlled (see `.gitignore`).

## Source

- **Movebank study ID:** 5109989622  
- **Species:** Fuegian Snipe *Gallinago stricklandii*  
- **Individuals:** 2 adults (IDs 266503 and [second individual ID])  
- **Tags:** Lotek PinPoint GPS-Argos (~6 g), leg-loop harness  
- **Deployment:** Parque La Tapera, Aysén Region, Chile (~48°S)  
- **Period:** December 2021 – December 2022 (full annual cycle)  
- **Fix schedule:** 1 location per 8 days (original deployment); see manuscript for details  

## Columns (standard Movebank export)

| Column | Description |
|--------|-------------|
| `event.id` | Unique fix identifier |
| `timestamp` | Date and time of fix (UTC) |
| `location.long` | Longitude (decimal degrees, WGS84) |
| `location.lat` | Latitude (decimal degrees, WGS84) |
| `individual.local.identifier` | Individual bird ID |
| `tag.local.identifier` | Tag serial number |
| `sensor.type` | `GPS` or `Argos Doppler Shift` |
| `argos.lc` | Argos location class (Doppler fixes only) |
| `ground.speed` | Ground speed (m/s), where available |
| `heading` | Heading (degrees), where available |
| `comments` | Notes on individual fixes |

## Filtering applied in `R/01_load_clean.R`

- Argos Doppler-derived fixes (`sensor.type == "Argos Doppler Shift"`) are retained in the raw data but **excluded from AKDE estimation** due to lower positional accuracy; they are used for visual inspection only.
- Fixes flagged as outliers by Movebank's automated detection are removed.

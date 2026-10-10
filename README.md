# Fishing Removal Calculator – Central Zone (Venezuela)

Interactive R/Shiny application that converts landed commercial biomass (kg) into an estimated number of individuals for four pelagic species caught in Venezuela's central zone:

- Blue marlin (BUM)
- Sailfish (SFA)
- White marlin (WHM)
- Skipjack tuna (SKJ)

**Live app:** https://e8jvsj-david-gomez.shinyapps.io/calculadora-remocion-zona-central/

## Why it exists

Landings are reported in kilograms, but management and stock-assessment work needs numbers of fish. Generic Atlantic-wide averages do not reflect local fish sizes, so this tool replaces them with a **biometric matrix calibrated on local measurements** (4,074 records).

## What it does

- Takes landed weight (kg) per species and returns the estimated number of individuals.
- Handles presentation conversions between round weight (RWT), gutted weight (GWT) and dressed weight (DWT), with species-specific conversion factors (SKJ: 1.13 / 1.25; other species: 1.12 / 1.20).
- Reports uncertainty as a **biological range (P10–P90 percentiles)** together with a **95% confidence interval of the mean** (mean ± 1.96 × SE).

## Method

1. Calibrate species-level biometric parameters from the local measurement database.
2. Convert landed weight to round weight using the presentation factors.
3. Divide by the calibrated mean individual weight to estimate the number of fish.
4. Propagate the P10–P90 range and the 95% CI to give a lower, central and upper estimate.

[Add formulas or a short protocol link if you want to publish them.]

## Run locally

```r
install.packages(c("shiny", "dplyr", "ggplot2"))  # adjust to the packages the app uses
shiny::runApp("app")                              # folder containing app.R
```

## Data

The repository contains **example data only**. The full calibration database is not included.

## Project structure

```
app/
  app.R
  R/            # helper functions
data-example/   # synthetic or anonymized sample data
README.md
```

## Roadmap

Recalibration of blue marlin and white marlin parameters as new measurements are collected.

## Author

David Alexander Gómez Segredo – Fisheries data analyst, Venezuela.
Contact: mathias110390@gmail.com

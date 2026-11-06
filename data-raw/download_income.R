library(tidycensus)
library(dplyr)
library(readr)

county_shapes <- get_acs(
  geography = "county",
  variables = "B19013_001",
  year = 2023,
  state = "FL",
  survey = "acs5",
  geometry = TRUE
)

income <- county_shapes |>
  sf::st_drop_geometry() |>
  transmute(GEOID, county = NAME, year = 2023, estimate, moe)

for (year in 2010:2022) {
  message("Downloading ACS ", year, " 5-year estimate")

  year_data <- get_acs(
    geography = "county",
    variables = "B19013_001",
    year = year,
    state = "FL",
    survey = "acs5",
    geometry = FALSE
  ) |>
    transmute(GEOID, county = NAME, year = year, estimate, moe)

  income <- bind_rows(income, year_data)
}

dir.create("data", showWarnings = FALSE)
write_csv(arrange(income, GEOID, year), "data/median_income.csv")

sf::st_write(
  county_shapes |> select(GEOID, NAME, geometry),
  "data/florida_counties.geojson",
  delete_dsn = TRUE,
  quiet = TRUE
)

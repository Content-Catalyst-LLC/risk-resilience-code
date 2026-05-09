library(readr)
library(dplyr)

input_file <- "../data/raw/urban_informality_risk_exposure_panel.csv"
city_output_file <- "../outputs/urban_informality_city_summary.csv"
settlement_output_file <- "../outputs/urban_informality_settlement_type_summary.csv"

urban_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "settlement_name",
  "city",
  "country_or_region",
  "settlement_type",
  "flood_exposure_index",
  "heat_exposure_index",
  "landslide_or_fire_exposure_index",
  "housing_vulnerability_index",
  "infrastructure_deficit_index",
  "service_access_index",
  "tenure_security_index",
  "livelihood_precarity_index",
  "social_protection_access_index",
  "community_adaptation_index",
  "institutional_protection_index",
  "climate_stress_index",
  "displacement_pressure_index",
  "data_visibility_index"
)

missing_cols <- setdiff(required_cols, names(urban_df))
if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(urban_df)[grepl("_index$", names(urban_df))]
invalid_index_cols <- index_cols[
  vapply(
    urban_df[index_cols],
    function(x) any(is.na(x) | x < 0 | x > 1),
    logical(1)
  )
]

if (length(invalid_index_cols) > 0) {
  stop(
    paste(
      "Index columns must be complete and normalized to [0, 1]:",
      paste(invalid_index_cols, collapse = ", ")
    )
  )
}

urban_df <- urban_df %>%
  mutate(
    hazard_exposure_proxy = (
      flood_exposure_index +
        heat_exposure_index +
        landslide_or_fire_exposure_index
    ) / 3,
    urban_vulnerability_proxy = (
      housing_vulnerability_index +
        infrastructure_deficit_index +
        livelihood_precarity_index +
        (1 - tenure_security_index) +
        displacement_pressure_index +
        (1 - social_protection_access_index)
    ) / 6,
    risk_exposure_proxy = (
      hazard_exposure_proxy +
        urban_vulnerability_proxy +
        climate_stress_index +
        infrastructure_deficit_index +
        displacement_pressure_index
    ) / 5,
    inclusive_protection_capacity_proxy = (
      service_access_index +
        tenure_security_index +
        community_adaptation_index +
        institutional_protection_index +
        social_protection_access_index +
        data_visibility_index +
        (1 - infrastructure_deficit_index)
    ) / 7,
    urban_protection_gap = inclusive_protection_capacity_proxy -
      risk_exposure_proxy,
    risk_band = case_when(
      risk_exposure_proxy >= 0.75 ~ "Severe urban risk exposure",
      risk_exposure_proxy >= 0.55 ~ "High urban risk exposure",
      risk_exposure_proxy >= 0.35 ~ "Moderate urban risk exposure",
      TRUE ~ "Lower urban risk exposure"
    )
  )

city_summary <- urban_df %>%
  group_by(city, country_or_region) %>%
  summarise(
    avg_risk_exposure = mean(risk_exposure_proxy, na.rm = TRUE),
    avg_inclusive_protection_capacity = mean(inclusive_protection_capacity_proxy, na.rm = TRUE),
    avg_urban_protection_gap = mean(urban_protection_gap, na.rm = TRUE),
    avg_hazard_exposure = mean(hazard_exposure_proxy, na.rm = TRUE),
    avg_urban_vulnerability = mean(urban_vulnerability_proxy, na.rm = TRUE),
    avg_flood_exposure = mean(flood_exposure_index, na.rm = TRUE),
    avg_heat_exposure = mean(heat_exposure_index, na.rm = TRUE),
    avg_housing_vulnerability = mean(housing_vulnerability_index, na.rm = TRUE),
    avg_infrastructure_deficit = mean(infrastructure_deficit_index, na.rm = TRUE),
    avg_service_access = mean(service_access_index, na.rm = TRUE),
    avg_tenure_security = mean(tenure_security_index, na.rm = TRUE),
    avg_livelihood_precarity = mean(livelihood_precarity_index, na.rm = TRUE),
    avg_social_protection_access = mean(social_protection_access_index, na.rm = TRUE),
    avg_community_adaptation = mean(community_adaptation_index, na.rm = TRUE),
    avg_institutional_protection = mean(institutional_protection_index, na.rm = TRUE),
    settlements = n(),
    .groups = "drop"
  ) %>%
  arrange(avg_urban_protection_gap)

settlement_summary <- urban_df %>%
  group_by(settlement_type) %>%
  summarise(
    avg_risk_exposure = mean(risk_exposure_proxy, na.rm = TRUE),
    avg_inclusive_protection_capacity = mean(inclusive_protection_capacity_proxy, na.rm = TRUE),
    avg_urban_protection_gap = mean(urban_protection_gap, na.rm = TRUE),
    avg_hazard_exposure = mean(hazard_exposure_proxy, na.rm = TRUE),
    avg_urban_vulnerability = mean(urban_vulnerability_proxy, na.rm = TRUE),
    avg_flood_exposure = mean(flood_exposure_index, na.rm = TRUE),
    avg_heat_exposure = mean(heat_exposure_index, na.rm = TRUE),
    avg_housing_vulnerability = mean(housing_vulnerability_index, na.rm = TRUE),
    avg_infrastructure_deficit = mean(infrastructure_deficit_index, na.rm = TRUE),
    avg_service_access = mean(service_access_index, na.rm = TRUE),
    avg_tenure_security = mean(tenure_security_index, na.rm = TRUE),
    avg_livelihood_precarity = mean(livelihood_precarity_index, na.rm = TRUE),
    avg_social_protection_access = mean(social_protection_access_index, na.rm = TRUE),
    avg_community_adaptation = mean(community_adaptation_index, na.rm = TRUE),
    avg_institutional_protection = mean(institutional_protection_index, na.rm = TRUE),
    settlements = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_risk_exposure))

write_csv(city_summary, city_output_file)
write_csv(settlement_summary, settlement_output_file)

cat("Urban informality city summary exported to:", city_output_file, "\n")
print(city_summary)

cat("\nUrban informality settlement-type summary exported to:", settlement_output_file, "\n")
print(settlement_summary)

library(readr)
library(dplyr)

input_file <- "../data/raw/regenerative_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/regenerative_resilience_jurisdiction_summary.csv"
system_output_file <- "../outputs/regenerative_resilience_system_type_summary.csv"

regen_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "jurisdiction",
  "system_type",
  "ecosystem_integrity_index",
  "biodiversity_index",
  "soil_health_index",
  "water_function_index",
  "connectivity_index",
  "local_stewardship_index",
  "governance_accountability_index",
  "justice_repair_index",
  "monitoring_quality_index",
  "degradation_pressure_index",
  "fragmentation_pressure_index",
  "extraction_pressure_index",
  "pollution_pressure_index",
  "climate_stress_index",
  "maladaptation_risk_index"
)

missing_cols <- setdiff(required_cols, names(regen_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(regen_df)[grepl("_index$", names(regen_df))]

invalid_index_cols <- index_cols[
  vapply(
    regen_df[index_cols],
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

regen_df <- regen_df %>%
  mutate(
    regenerative_capacity_proxy = (
      ecosystem_integrity_index +
        biodiversity_index +
        soil_health_index +
        water_function_index +
        connectivity_index +
        local_stewardship_index +
        governance_accountability_index +
        justice_repair_index +
        monitoring_quality_index
    ) / 9,
    degradation_pressure_proxy = (
      degradation_pressure_index +
        fragmentation_pressure_index +
        extraction_pressure_index +
        pollution_pressure_index +
        climate_stress_index +
        maladaptation_risk_index
    ) / 6,
    living_systems_repair_gap = regenerative_capacity_proxy -
      degradation_pressure_proxy,
    regenerative_resilience_band = case_when(
      regenerative_capacity_proxy >= 0.75 ~ "Strong regenerative resilience",
      regenerative_capacity_proxy >= 0.55 ~ "Moderate regenerative resilience",
      regenerative_capacity_proxy >= 0.35 ~ "Limited regenerative resilience",
      TRUE ~ "Weak regenerative resilience"
    )
  )

jurisdiction_summary <- regen_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_regenerative_capacity = mean(regenerative_capacity_proxy, na.rm = TRUE),
    avg_degradation_pressure = mean(degradation_pressure_proxy, na.rm = TRUE),
    avg_living_systems_repair_gap = mean(living_systems_repair_gap, na.rm = TRUE),
    avg_ecosystem_integrity = mean(ecosystem_integrity_index, na.rm = TRUE),
    avg_biodiversity = mean(biodiversity_index, na.rm = TRUE),
    avg_soil_health = mean(soil_health_index, na.rm = TRUE),
    avg_water_function = mean(water_function_index, na.rm = TRUE),
    avg_connectivity = mean(connectivity_index, na.rm = TRUE),
    avg_local_stewardship = mean(local_stewardship_index, na.rm = TRUE),
    avg_governance_accountability = mean(governance_accountability_index, na.rm = TRUE),
    avg_justice_repair = mean(justice_repair_index, na.rm = TRUE),
    avg_degradation_pressure_index = mean(degradation_pressure_index, na.rm = TRUE),
    avg_fragmentation_pressure = mean(fragmentation_pressure_index, na.rm = TRUE),
    avg_extraction_pressure = mean(extraction_pressure_index, na.rm = TRUE),
    avg_pollution_pressure = mean(pollution_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_living_systems_repair_gap))

system_summary <- regen_df %>%
  group_by(system_type) %>%
  summarise(
    avg_regenerative_capacity = mean(regenerative_capacity_proxy, na.rm = TRUE),
    avg_degradation_pressure = mean(degradation_pressure_proxy, na.rm = TRUE),
    avg_living_systems_repair_gap = mean(living_systems_repair_gap, na.rm = TRUE),
    avg_ecosystem_integrity = mean(ecosystem_integrity_index, na.rm = TRUE),
    avg_biodiversity = mean(biodiversity_index, na.rm = TRUE),
    avg_soil_health = mean(soil_health_index, na.rm = TRUE),
    avg_water_function = mean(water_function_index, na.rm = TRUE),
    avg_connectivity = mean(connectivity_index, na.rm = TRUE),
    avg_local_stewardship = mean(local_stewardship_index, na.rm = TRUE),
    avg_governance_accountability = mean(governance_accountability_index, na.rm = TRUE),
    avg_justice_repair = mean(justice_repair_index, na.rm = TRUE),
    avg_degradation_pressure_index = mean(degradation_pressure_index, na.rm = TRUE),
    avg_fragmentation_pressure = mean(fragmentation_pressure_index, na.rm = TRUE),
    avg_extraction_pressure = mean(extraction_pressure_index, na.rm = TRUE),
    avg_pollution_pressure = mean(pollution_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_degradation_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_summary, system_output_file)

cat("Regenerative resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nRegenerative resilience system-type summary exported to:", system_output_file, "\n")
print(system_summary)

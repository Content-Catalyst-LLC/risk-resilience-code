library(readr)
library(dplyr)

input_file <- "../data/raw/drinking_water_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/drinking_water_jurisdiction_summary.csv"
system_type_output_file <- "../outputs/drinking_water_system_type_summary.csv"

water_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "water_system_name",
  "jurisdiction",
  "system_type",
  "source_protection_index",
  "treatment_capacity_index",
  "distribution_reliability_index",
  "monitoring_quality_index",
  "supply_diversity_index",
  "energy_resilience_index",
  "affordability_index",
  "governance_capacity_index",
  "contamination_risk_index",
  "infrastructure_aging_index",
  "salinity_pressure_index",
  "energy_dependence_index",
  "brine_burden_index",
  "access_inequality_index"
)

missing_cols <- setdiff(required_cols, names(water_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(water_df)[grepl("_index$", names(water_df))]

invalid_index_cols <- index_cols[
  vapply(
    water_df[index_cols],
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

water_df <- water_df %>%
  mutate(
    water_resilience_capacity_proxy = (
      source_protection_index +
        treatment_capacity_index +
        distribution_reliability_index +
        monitoring_quality_index +
        supply_diversity_index +
        energy_resilience_index +
        affordability_index +
        governance_capacity_index
    ) / 8,
    water_system_risk_pressure_proxy = (
      contamination_risk_index +
        infrastructure_aging_index +
        salinity_pressure_index +
        energy_dependence_index +
        brine_burden_index +
        access_inequality_index
    ) / 6,
    drinking_water_resilience_proxy = (
      water_resilience_capacity_proxy +
        (1 - water_system_risk_pressure_proxy)
    ) / 2,
    source_to_tap_resilience_gap = water_resilience_capacity_proxy -
      water_system_risk_pressure_proxy,
    resilience_band = case_when(
      drinking_water_resilience_proxy >= 0.75 ~ "Strong drinking-water resilience",
      drinking_water_resilience_proxy >= 0.55 ~ "Moderate drinking-water resilience",
      drinking_water_resilience_proxy >= 0.35 ~ "Limited drinking-water resilience",
      TRUE ~ "Weak drinking-water resilience"
    )
  )

jurisdiction_summary <- water_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_drinking_water_resilience = mean(drinking_water_resilience_proxy, na.rm = TRUE),
    avg_water_resilience_capacity = mean(water_resilience_capacity_proxy, na.rm = TRUE),
    avg_water_system_risk_pressure = mean(water_system_risk_pressure_proxy, na.rm = TRUE),
    avg_source_to_tap_resilience_gap = mean(source_to_tap_resilience_gap, na.rm = TRUE),
    avg_source_protection = mean(source_protection_index, na.rm = TRUE),
    avg_treatment_capacity = mean(treatment_capacity_index, na.rm = TRUE),
    avg_distribution_reliability = mean(distribution_reliability_index, na.rm = TRUE),
    avg_monitoring_quality = mean(monitoring_quality_index, na.rm = TRUE),
    avg_supply_diversity = mean(supply_diversity_index, na.rm = TRUE),
    avg_energy_resilience = mean(energy_resilience_index, na.rm = TRUE),
    avg_affordability = mean(affordability_index, na.rm = TRUE),
    avg_governance_capacity = mean(governance_capacity_index, na.rm = TRUE),
    avg_contamination_risk = mean(contamination_risk_index, na.rm = TRUE),
    avg_infrastructure_aging = mean(infrastructure_aging_index, na.rm = TRUE),
    avg_salinity_pressure = mean(salinity_pressure_index, na.rm = TRUE),
    avg_energy_dependence = mean(energy_dependence_index, na.rm = TRUE),
    avg_brine_burden = mean(brine_burden_index, na.rm = TRUE),
    avg_access_inequality = mean(access_inequality_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_drinking_water_resilience))

system_type_summary <- water_df %>%
  group_by(system_type) %>%
  summarise(
    avg_drinking_water_resilience = mean(drinking_water_resilience_proxy, na.rm = TRUE),
    avg_water_resilience_capacity = mean(water_resilience_capacity_proxy, na.rm = TRUE),
    avg_water_system_risk_pressure = mean(water_system_risk_pressure_proxy, na.rm = TRUE),
    avg_source_to_tap_resilience_gap = mean(source_to_tap_resilience_gap, na.rm = TRUE),
    avg_source_protection = mean(source_protection_index, na.rm = TRUE),
    avg_treatment_capacity = mean(treatment_capacity_index, na.rm = TRUE),
    avg_distribution_reliability = mean(distribution_reliability_index, na.rm = TRUE),
    avg_monitoring_quality = mean(monitoring_quality_index, na.rm = TRUE),
    avg_supply_diversity = mean(supply_diversity_index, na.rm = TRUE),
    avg_energy_resilience = mean(energy_resilience_index, na.rm = TRUE),
    avg_affordability = mean(affordability_index, na.rm = TRUE),
    avg_governance_capacity = mean(governance_capacity_index, na.rm = TRUE),
    avg_contamination_risk = mean(contamination_risk_index, na.rm = TRUE),
    avg_infrastructure_aging = mean(infrastructure_aging_index, na.rm = TRUE),
    avg_salinity_pressure = mean(salinity_pressure_index, na.rm = TRUE),
    avg_energy_dependence = mean(energy_dependence_index, na.rm = TRUE),
    avg_brine_burden = mean(brine_burden_index, na.rm = TRUE),
    avg_access_inequality = mean(access_inequality_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_water_system_risk_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_type_summary, system_type_output_file)

cat("Drinking-water jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nDrinking-water system-type summary exported to:", system_type_output_file, "\n")
print(system_type_summary)

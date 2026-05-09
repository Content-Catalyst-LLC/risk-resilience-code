library(readr)
library(dplyr)

input_file <- "../data/raw/energy_security_grid_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/energy_resilience_jurisdiction_summary.csv"
system_type_output_file <- "../outputs/energy_resilience_system_type_summary.csv"

energy_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "energy_system_name",
  "jurisdiction",
  "system_type",
  "reliability_index",
  "adequacy_index",
  "redundancy_index",
  "flexibility_index",
  "distributed_capacity_index",
  "cyber_resilience_index",
  "restoration_capacity_index",
  "critical_load_protection_index",
  "affordability_index",
  "equity_protection_index",
  "climate_exposure_index",
  "infrastructure_aging_index",
  "fuel_dependence_index",
  "digital_fragility_index",
  "load_growth_pressure_index",
  "interdependency_risk_index"
)

missing_cols <- setdiff(required_cols, names(energy_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(energy_df)[grepl("_index$", names(energy_df))]

invalid_index_cols <- index_cols[
  vapply(
    energy_df[index_cols],
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

energy_df <- energy_df %>%
  mutate(
    energy_resilience_capacity_proxy = (
      reliability_index +
        adequacy_index +
        redundancy_index +
        flexibility_index +
        distributed_capacity_index +
        cyber_resilience_index +
        restoration_capacity_index +
        critical_load_protection_index
    ) / 8,
    grid_fragility_pressure_proxy = (
      climate_exposure_index +
        infrastructure_aging_index +
        fuel_dependence_index +
        digital_fragility_index +
        load_growth_pressure_index +
        interdependency_risk_index
    ) / 6,
    just_energy_resilience_proxy = (
      affordability_index +
        equity_protection_index +
        critical_load_protection_index +
        distributed_capacity_index +
        restoration_capacity_index
    ) / 5,
    energy_security_resilience_proxy = (
      energy_resilience_capacity_proxy +
        just_energy_resilience_proxy +
        (1 - grid_fragility_pressure_proxy)
    ) / 3,
    resilience_fragility_gap = energy_resilience_capacity_proxy -
      grid_fragility_pressure_proxy,
    resilience_band = case_when(
      energy_security_resilience_proxy >= 0.75 ~ "Strong energy security resilience",
      energy_security_resilience_proxy >= 0.55 ~ "Moderate energy security resilience",
      energy_security_resilience_proxy >= 0.35 ~ "Limited energy security resilience",
      TRUE ~ "Weak energy security resilience"
    )
  )

jurisdiction_summary <- energy_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_energy_security_resilience = mean(energy_security_resilience_proxy, na.rm = TRUE),
    avg_energy_resilience_capacity = mean(energy_resilience_capacity_proxy, na.rm = TRUE),
    avg_grid_fragility_pressure = mean(grid_fragility_pressure_proxy, na.rm = TRUE),
    avg_just_energy_resilience = mean(just_energy_resilience_proxy, na.rm = TRUE),
    avg_resilience_fragility_gap = mean(resilience_fragility_gap, na.rm = TRUE),
    avg_reliability = mean(reliability_index, na.rm = TRUE),
    avg_adequacy = mean(adequacy_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_flexibility = mean(flexibility_index, na.rm = TRUE),
    avg_distributed_capacity = mean(distributed_capacity_index, na.rm = TRUE),
    avg_cyber_resilience = mean(cyber_resilience_index, na.rm = TRUE),
    avg_restoration_capacity = mean(restoration_capacity_index, na.rm = TRUE),
    avg_critical_load_protection = mean(critical_load_protection_index, na.rm = TRUE),
    avg_affordability = mean(affordability_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_climate_exposure = mean(climate_exposure_index, na.rm = TRUE),
    avg_infrastructure_aging = mean(infrastructure_aging_index, na.rm = TRUE),
    avg_fuel_dependence = mean(fuel_dependence_index, na.rm = TRUE),
    avg_digital_fragility = mean(digital_fragility_index, na.rm = TRUE),
    avg_load_growth_pressure = mean(load_growth_pressure_index, na.rm = TRUE),
    avg_interdependency_risk = mean(interdependency_risk_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_energy_security_resilience))

system_type_summary <- energy_df %>%
  group_by(system_type) %>%
  summarise(
    avg_energy_security_resilience = mean(energy_security_resilience_proxy, na.rm = TRUE),
    avg_energy_resilience_capacity = mean(energy_resilience_capacity_proxy, na.rm = TRUE),
    avg_grid_fragility_pressure = mean(grid_fragility_pressure_proxy, na.rm = TRUE),
    avg_just_energy_resilience = mean(just_energy_resilience_proxy, na.rm = TRUE),
    avg_resilience_fragility_gap = mean(resilience_fragility_gap, na.rm = TRUE),
    avg_reliability = mean(reliability_index, na.rm = TRUE),
    avg_adequacy = mean(adequacy_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_flexibility = mean(flexibility_index, na.rm = TRUE),
    avg_distributed_capacity = mean(distributed_capacity_index, na.rm = TRUE),
    avg_cyber_resilience = mean(cyber_resilience_index, na.rm = TRUE),
    avg_restoration_capacity = mean(restoration_capacity_index, na.rm = TRUE),
    avg_critical_load_protection = mean(critical_load_protection_index, na.rm = TRUE),
    avg_affordability = mean(affordability_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_climate_exposure = mean(climate_exposure_index, na.rm = TRUE),
    avg_infrastructure_aging = mean(infrastructure_aging_index, na.rm = TRUE),
    avg_fuel_dependence = mean(fuel_dependence_index, na.rm = TRUE),
    avg_digital_fragility = mean(digital_fragility_index, na.rm = TRUE),
    avg_load_growth_pressure = mean(load_growth_pressure_index, na.rm = TRUE),
    avg_interdependency_risk = mean(interdependency_risk_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_grid_fragility_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_type_summary, system_type_output_file)

cat("Energy resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nEnergy resilience system-type summary exported to:", system_type_output_file, "\n")
print(system_type_summary)

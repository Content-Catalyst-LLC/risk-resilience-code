library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_design_system_panel.csv"
sector_output_file <- "../outputs/sector_resilience_design_summary.csv"
system_type_output_file <- "../outputs/system_type_resilience_design_summary.csv"

resilience_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "system_type",
  "normal_performance_index",
  "cost_efficiency_index",
  "utilization_pressure_index",
  "slack_capacity_index",
  "redundancy_capacity_index",
  "flexibility_capacity_index",
  "modularity_index",
  "dependency_visibility_index",
  "dependency_concentration_index",
  "tight_coupling_index",
  "maintenance_vulnerability_index",
  "cyber_exposure_index",
  "climate_hazard_exposure_index",
  "service_criticality_index",
  "governance_capacity_index",
  "recovery_capacity_index",
  "equity_vulnerability_index"
)

missing_cols <- setdiff(required_cols, names(resilience_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

resilience_df <- resilience_df %>%
  mutate(
    optimization_fragility_proxy = (
      utilization_pressure_index +
        (1 - slack_capacity_index) +
        (1 - redundancy_capacity_index) +
        dependency_concentration_index +
        tight_coupling_index +
        maintenance_vulnerability_index +
        cyber_exposure_index +
        climate_hazard_exposure_index +
        (1 - dependency_visibility_index)
    ) / 9,
    resilience_capacity_proxy = (
      slack_capacity_index +
        redundancy_capacity_index +
        flexibility_capacity_index +
        modularity_index +
        dependency_visibility_index +
        governance_capacity_index +
        recovery_capacity_index +
        (1 - equity_vulnerability_index)
    ) / 8,
    resilience_adjusted_design_proxy = (
      optimization_fragility_proxy +
        (1 - resilience_capacity_proxy) +
        service_criticality_index +
        equity_vulnerability_index +
        cyber_exposure_index +
        climate_hazard_exposure_index
    ) / 6,
    resilience_gap = optimization_fragility_proxy - resilience_capacity_proxy,
    risk_band = case_when(
      resilience_adjusted_design_proxy >= 0.75 ~ "Extreme resilience-design risk",
      resilience_adjusted_design_proxy >= 0.55 ~ "High resilience-design risk",
      resilience_adjusted_design_proxy >= 0.35 ~ "Moderate resilience-design risk",
      TRUE ~ "Lower resilience-design risk"
    )
  )

sector_summary <- resilience_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_adjusted_design_proxy = mean(resilience_adjusted_design_proxy, na.rm = TRUE),
    avg_optimization_fragility_proxy = mean(optimization_fragility_proxy, na.rm = TRUE),
    avg_resilience_capacity_proxy = mean(resilience_capacity_proxy, na.rm = TRUE),
    avg_resilience_gap = mean(resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_design_proxy))

system_type_summary <- resilience_df %>%
  group_by(system_type) %>%
  summarise(
    avg_resilience_adjusted_design_proxy = mean(resilience_adjusted_design_proxy, na.rm = TRUE),
    avg_optimization_fragility_proxy = mean(optimization_fragility_proxy, na.rm = TRUE),
    avg_resilience_capacity_proxy = mean(resilience_capacity_proxy, na.rm = TRUE),
    avg_resilience_gap = mean(resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_design_proxy))

write_csv(sector_summary, sector_output_file)
write_csv(system_type_summary, system_type_output_file)

cat("Sector resilience-design summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nSystem-type resilience-design summary exported to:", system_type_output_file, "\n")
print(system_type_summary)

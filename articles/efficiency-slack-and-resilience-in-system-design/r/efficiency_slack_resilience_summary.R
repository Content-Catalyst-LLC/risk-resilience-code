library(readr)
library(dplyr)

input_file <- "../data/raw/efficiency_slack_resilience_panel.csv"
sector_output_file <- "../outputs/efficiency_slack_sector_summary.csv"
system_type_output_file <- "../outputs/efficiency_slack_system_type_summary.csv"

system_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "system_type",
  "routine_efficiency_index",
  "protective_slack_index",
  "redundancy_index",
  "modularity_index",
  "diversity_index",
  "feedback_monitoring_index",
  "repair_capacity_index",
  "governance_quality_index",
  "tight_coupling_index",
  "single_point_dependence_index",
  "overload_index",
  "deferred_maintenance_index",
  "hidden_risk_transfer_index"
)

missing_cols <- setdiff(required_cols, names(system_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(system_df)[grepl("_index$", names(system_df))]

invalid_index_cols <- index_cols[
  vapply(
    system_df[index_cols],
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

system_df <- system_df %>%
  mutate(
    resilience_capacity_proxy = (
      routine_efficiency_index +
        protective_slack_index +
        redundancy_index +
        modularity_index +
        diversity_index +
        feedback_monitoring_index +
        repair_capacity_index +
        governance_quality_index
    ) / 8,
    optimization_fragility_pressure_proxy = (
      tight_coupling_index +
        single_point_dependence_index +
        overload_index +
        deferred_maintenance_index +
        hidden_risk_transfer_index
    ) / 5,
    resilience_aware_performance_proxy = (
      resilience_capacity_proxy +
        (1 - optimization_fragility_pressure_proxy)
    ) / 2,
    slack_fragility_gap = resilience_capacity_proxy -
      optimization_fragility_pressure_proxy,
    design_band = case_when(
      resilience_aware_performance_proxy >= 0.75 ~ "Resilient efficiency",
      resilience_aware_performance_proxy >= 0.55 ~ "Moderate resilience-aware performance",
      resilience_aware_performance_proxy >= 0.35 ~ "Limited resilience-aware performance",
      TRUE ~ "Fragility-producing optimization"
    )
  )

sector_summary <- system_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_aware_performance = mean(resilience_aware_performance_proxy, na.rm = TRUE),
    avg_resilience_capacity = mean(resilience_capacity_proxy, na.rm = TRUE),
    avg_optimization_fragility_pressure = mean(optimization_fragility_pressure_proxy, na.rm = TRUE),
    avg_slack_fragility_gap = mean(slack_fragility_gap, na.rm = TRUE),
    avg_routine_efficiency = mean(routine_efficiency_index, na.rm = TRUE),
    avg_protective_slack = mean(protective_slack_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_diversity = mean(diversity_index, na.rm = TRUE),
    avg_feedback_monitoring = mean(feedback_monitoring_index, na.rm = TRUE),
    avg_repair_capacity = mean(repair_capacity_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    avg_tight_coupling = mean(tight_coupling_index, na.rm = TRUE),
    avg_single_point_dependence = mean(single_point_dependence_index, na.rm = TRUE),
    avg_overload = mean(overload_index, na.rm = TRUE),
    avg_deferred_maintenance = mean(deferred_maintenance_index, na.rm = TRUE),
    avg_hidden_risk_transfer = mean(hidden_risk_transfer_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_optimization_fragility_pressure))

system_type_summary <- system_df %>%
  group_by(system_type) %>%
  summarise(
    avg_resilience_aware_performance = mean(resilience_aware_performance_proxy, na.rm = TRUE),
    avg_resilience_capacity = mean(resilience_capacity_proxy, na.rm = TRUE),
    avg_optimization_fragility_pressure = mean(optimization_fragility_pressure_proxy, na.rm = TRUE),
    avg_slack_fragility_gap = mean(slack_fragility_gap, na.rm = TRUE),
    avg_routine_efficiency = mean(routine_efficiency_index, na.rm = TRUE),
    avg_protective_slack = mean(protective_slack_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_diversity = mean(diversity_index, na.rm = TRUE),
    avg_feedback_monitoring = mean(feedback_monitoring_index, na.rm = TRUE),
    avg_repair_capacity = mean(repair_capacity_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    avg_tight_coupling = mean(tight_coupling_index, na.rm = TRUE),
    avg_single_point_dependence = mean(single_point_dependence_index, na.rm = TRUE),
    avg_overload = mean(overload_index, na.rm = TRUE),
    avg_deferred_maintenance = mean(deferred_maintenance_index, na.rm = TRUE),
    avg_hidden_risk_transfer = mean(hidden_risk_transfer_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_aware_performance))

write_csv(sector_summary, sector_output_file)
write_csv(system_type_summary, system_type_output_file)

cat("Efficiency/slack sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nEfficiency/slack system-type summary exported to:", system_type_output_file, "\n")
print(system_type_summary)

library(readr)
library(dplyr)

input_file <- "../data/raw/scenario_matrix_shock_library_panel.csv"
jurisdiction_output_file <- "../outputs/scenario_matrix_jurisdiction_summary.csv"
system_output_file <- "../outputs/scenario_matrix_system_type_summary.csv"

scenario_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "planning_system",
  "jurisdiction",
  "system_type",
  "scenario_coverage_index",
  "shock_library_quality_index",
  "shock_specificity_index",
  "compound_risk_coverage_index",
  "essential_function_mapping_index",
  "dependency_mapping_index",
  "trigger_readiness_index",
  "threshold_clarity_index",
  "equity_integration_index",
  "community_validation_index",
  "stress_test_linkage_index",
  "governance_ownership_index",
  "update_cadence_index",
  "action_linkage_index",
  "adaptive_decision_capacity_index",
  "compound_risk_exposure_index",
  "blind_spot_gap_index",
  "stale_assumption_risk_index",
  "scenario_theater_risk_index",
  "untested_fragility_index"
)

missing_cols <- setdiff(required_cols, names(scenario_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(scenario_df)[grepl("_index$", names(scenario_df))]

invalid_index_cols <- index_cols[
  vapply(
    scenario_df[index_cols],
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

scenario_df <- scenario_df %>%
  mutate(
    scenario_matrix_quality_proxy = (
      scenario_coverage_index +
        compound_risk_coverage_index +
        essential_function_mapping_index +
        dependency_mapping_index +
        trigger_readiness_index +
        threshold_clarity_index +
        equity_integration_index +
        stress_test_linkage_index
    ) / 8,
    shock_library_reliability_proxy = (
      shock_library_quality_index +
        shock_specificity_index +
        compound_risk_coverage_index +
        dependency_mapping_index +
        essential_function_mapping_index +
        community_validation_index +
        update_cadence_index +
        governance_ownership_index
    ) / 8,
    planning_actionability_proxy = (
      action_linkage_index +
        governance_ownership_index +
        trigger_readiness_index +
        threshold_clarity_index +
        stress_test_linkage_index +
        adaptive_decision_capacity_index +
        update_cadence_index
    ) / 7,
    blind_spot_pressure_proxy = (
      compound_risk_exposure_index +
        blind_spot_gap_index +
        stale_assumption_risk_index +
        scenario_theater_risk_index +
        untested_fragility_index +
        (1 - community_validation_index)
    ) / 6,
    resilience_planning_readiness_proxy = (
      scenario_matrix_quality_proxy +
        shock_library_reliability_proxy +
        planning_actionability_proxy +
        adaptive_decision_capacity_index +
        (1 - blind_spot_pressure_proxy)
    ) / 5,
    planning_readiness_gap = resilience_planning_readiness_proxy - blind_spot_pressure_proxy,
    planning_band = case_when(
      resilience_planning_readiness_proxy >= 0.75 ~ "Strong scenario-based resilience planning",
      resilience_planning_readiness_proxy >= 0.55 ~ "Moderate scenario-based resilience planning",
      resilience_planning_readiness_proxy >= 0.35 ~ "Limited scenario-based resilience planning",
      TRUE ~ "Weak scenario-based resilience planning"
    )
  )

jurisdiction_summary <- scenario_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_resilience_planning_readiness = mean(resilience_planning_readiness_proxy, na.rm = TRUE),
    avg_scenario_matrix_quality = mean(scenario_matrix_quality_proxy, na.rm = TRUE),
    avg_shock_library_reliability = mean(shock_library_reliability_proxy, na.rm = TRUE),
    avg_planning_actionability = mean(planning_actionability_proxy, na.rm = TRUE),
    avg_blind_spot_pressure = mean(blind_spot_pressure_proxy, na.rm = TRUE),
    avg_scenario_coverage = mean(scenario_coverage_index, na.rm = TRUE),
    avg_shock_library_quality = mean(shock_library_quality_index, na.rm = TRUE),
    avg_shock_specificity = mean(shock_specificity_index, na.rm = TRUE),
    avg_compound_risk_coverage = mean(compound_risk_coverage_index, na.rm = TRUE),
    avg_essential_function_mapping = mean(essential_function_mapping_index, na.rm = TRUE),
    avg_dependency_mapping = mean(dependency_mapping_index, na.rm = TRUE),
    avg_trigger_readiness = mean(trigger_readiness_index, na.rm = TRUE),
    avg_equity_integration = mean(equity_integration_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_compound_risk_exposure = mean(compound_risk_exposure_index, na.rm = TRUE),
    avg_scenario_theater_risk = mean(scenario_theater_risk_index, na.rm = TRUE),
    avg_planning_readiness_gap = mean(planning_readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_planning_readiness))

system_type_summary <- scenario_df %>%
  group_by(system_type) %>%
  summarise(
    avg_resilience_planning_readiness = mean(resilience_planning_readiness_proxy, na.rm = TRUE),
    avg_scenario_matrix_quality = mean(scenario_matrix_quality_proxy, na.rm = TRUE),
    avg_shock_library_reliability = mean(shock_library_reliability_proxy, na.rm = TRUE),
    avg_planning_actionability = mean(planning_actionability_proxy, na.rm = TRUE),
    avg_blind_spot_pressure = mean(blind_spot_pressure_proxy, na.rm = TRUE),
    avg_scenario_coverage = mean(scenario_coverage_index, na.rm = TRUE),
    avg_shock_library_quality = mean(shock_library_quality_index, na.rm = TRUE),
    avg_shock_specificity = mean(shock_specificity_index, na.rm = TRUE),
    avg_compound_risk_coverage = mean(compound_risk_coverage_index, na.rm = TRUE),
    avg_essential_function_mapping = mean(essential_function_mapping_index, na.rm = TRUE),
    avg_dependency_mapping = mean(dependency_mapping_index, na.rm = TRUE),
    avg_trigger_readiness = mean(trigger_readiness_index, na.rm = TRUE),
    avg_equity_integration = mean(equity_integration_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_compound_risk_exposure = mean(compound_risk_exposure_index, na.rm = TRUE),
    avg_scenario_theater_risk = mean(scenario_theater_risk_index, na.rm = TRUE),
    avg_planning_readiness_gap = mean(planning_readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_planning_readiness))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_type_summary, system_output_file)

cat("Scenario matrix jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nScenario matrix system-type summary exported to:", system_output_file, "\n")
print(system_type_summary)

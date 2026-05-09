library(readr)
library(dplyr)

input_file <- "../data/raw/environmental_monitoring_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/environmental_monitoring_jurisdiction_summary.csv"
domain_output_file <- "../outputs/environmental_monitoring_domain_summary.csv"

monitor_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "monitoring_system_name",
  "jurisdiction",
  "system_domain",
  "observation_coverage_index",
  "data_quality_index",
  "timeliness_index",
  "interoperability_index",
  "analytical_capacity_index",
  "warning_dissemination_index",
  "community_validation_index",
  "action_linkage_index",
  "rights_safeguard_index",
  "blind_spot_index",
  "uncertainty_burden_index",
  "decision_lag_index",
  "maintenance_risk_index",
  "misuse_risk_index"
)

missing_cols <- setdiff(required_cols, names(monitor_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(monitor_df)[grepl("_index$", names(monitor_df))]

invalid_index_cols <- index_cols[
  vapply(
    monitor_df[index_cols],
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

monitor_df <- monitor_df %>%
  mutate(
    monitoring_capacity_proxy = (
      observation_coverage_index +
        data_quality_index +
        timeliness_index +
        interoperability_index +
        analytical_capacity_index +
        warning_dissemination_index +
        community_validation_index +
        action_linkage_index +
        rights_safeguard_index
    ) / 9,
    monitoring_risk_pressure_proxy = (
      blind_spot_index +
        uncertainty_burden_index +
        decision_lag_index +
        maintenance_risk_index +
        misuse_risk_index
    ) / 5,
    monitoring_supported_resilience_proxy = (
      monitoring_capacity_proxy +
        action_linkage_index +
        rights_safeguard_index +
        (1 - monitoring_risk_pressure_proxy)
    ) / 4,
    monitoring_action_gap = monitoring_capacity_proxy - action_linkage_index,
    monitoring_band = case_when(
      monitoring_supported_resilience_proxy >= 0.75 ~ "Strong monitoring-supported resilience",
      monitoring_supported_resilience_proxy >= 0.55 ~ "Moderate monitoring-supported resilience",
      monitoring_supported_resilience_proxy >= 0.35 ~ "Limited monitoring-supported resilience",
      TRUE ~ "Weak monitoring-supported resilience"
    )
  )

jurisdiction_summary <- monitor_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_monitoring_supported_resilience = mean(monitoring_supported_resilience_proxy, na.rm = TRUE),
    avg_monitoring_capacity = mean(monitoring_capacity_proxy, na.rm = TRUE),
    avg_monitoring_risk_pressure = mean(monitoring_risk_pressure_proxy, na.rm = TRUE),
    avg_monitoring_action_gap = mean(monitoring_action_gap, na.rm = TRUE),
    avg_observation_coverage = mean(observation_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_timeliness = mean(timeliness_index, na.rm = TRUE),
    avg_interoperability = mean(interoperability_index, na.rm = TRUE),
    avg_analytical_capacity = mean(analytical_capacity_index, na.rm = TRUE),
    avg_warning_dissemination = mean(warning_dissemination_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_rights_safeguard = mean(rights_safeguard_index, na.rm = TRUE),
    avg_blind_spots = mean(blind_spot_index, na.rm = TRUE),
    avg_decision_lag = mean(decision_lag_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_monitoring_supported_resilience))

domain_summary <- monitor_df %>%
  group_by(system_domain) %>%
  summarise(
    avg_monitoring_supported_resilience = mean(monitoring_supported_resilience_proxy, na.rm = TRUE),
    avg_monitoring_capacity = mean(monitoring_capacity_proxy, na.rm = TRUE),
    avg_monitoring_risk_pressure = mean(monitoring_risk_pressure_proxy, na.rm = TRUE),
    avg_monitoring_action_gap = mean(monitoring_action_gap, na.rm = TRUE),
    avg_observation_coverage = mean(observation_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_timeliness = mean(timeliness_index, na.rm = TRUE),
    avg_interoperability = mean(interoperability_index, na.rm = TRUE),
    avg_analytical_capacity = mean(analytical_capacity_index, na.rm = TRUE),
    avg_warning_dissemination = mean(warning_dissemination_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_rights_safeguard = mean(rights_safeguard_index, na.rm = TRUE),
    avg_blind_spots = mean(blind_spot_index, na.rm = TRUE),
    avg_decision_lag = mean(decision_lag_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_monitoring_risk_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Environmental monitoring jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nEnvironmental monitoring domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

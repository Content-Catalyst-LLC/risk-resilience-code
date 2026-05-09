library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_indicators_panel.csv"
jurisdiction_output_file <- "../outputs/resilience_indicators_jurisdiction_summary.csv"
system_output_file <- "../outputs/resilience_indicators_system_type_summary.csv"

indicator_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "jurisdiction",
  "system_type",
  "capacity_index",
  "asset_index",
  "process_index",
  "outcome_index",
  "equity_protection_index",
  "service_continuity_index",
  "recovery_performance_index",
  "adaptive_learning_index",
  "institutional_capacity_index",
  "ecological_condition_index",
  "social_protection_index",
  "financial_protection_index",
  "vulnerability_index",
  "exposure_index",
  "distributional_inequality_index",
  "measurement_uncertainty_index",
  "data_quality_gap_index",
  "false_precision_risk_index"
)

missing_cols <- setdiff(required_cols, names(indicator_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(indicator_df)[grepl("_index$", names(indicator_df))]

invalid_index_cols <- index_cols[
  vapply(
    indicator_df[index_cols],
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

indicator_df <- indicator_df %>%
  mutate(
    capacity_asset_process_proxy = (
      capacity_index + asset_index + process_index
    ) / 3,
    performance_outcome_proxy = (
      outcome_index +
        service_continuity_index +
        recovery_performance_index +
        adaptive_learning_index +
        institutional_capacity_index +
        ecological_condition_index +
        social_protection_index
    ) / 7,
    measurement_vulnerability_proxy = (
      vulnerability_index +
        exposure_index +
        distributional_inequality_index +
        measurement_uncertainty_index +
        data_quality_gap_index +
        false_precision_risk_index
    ) / 6,
    measured_resilience_proxy = (
      capacity_asset_process_proxy +
        performance_outcome_proxy +
        equity_protection_index +
        financial_protection_index +
        (1 - measurement_vulnerability_proxy)
    ) / 5,
    equity_adjusted_resilience_proxy = pmax(
      measured_resilience_proxy -
        0.25 * distributional_inequality_index -
        0.15 * (1 - equity_protection_index),
      0
    ),
    indicator_confidence_proxy = (
      (1 - measurement_uncertainty_index) +
        (1 - data_quality_gap_index) +
        (1 - false_precision_risk_index)
    ) / 3,
    measurement_gap = measured_resilience_proxy - measurement_vulnerability_proxy,
    resilience_band = case_when(
      equity_adjusted_resilience_proxy >= 0.75 ~ "Strong equity-adjusted measured resilience",
      equity_adjusted_resilience_proxy >= 0.55 ~ "Moderate equity-adjusted measured resilience",
      equity_adjusted_resilience_proxy >= 0.35 ~ "Limited equity-adjusted measured resilience",
      TRUE ~ "Weak equity-adjusted measured resilience"
    )
  )

jurisdiction_summary <- indicator_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_equity_adjusted_resilience = mean(equity_adjusted_resilience_proxy, na.rm = TRUE),
    avg_measured_resilience = mean(measured_resilience_proxy, na.rm = TRUE),
    avg_indicator_confidence = mean(indicator_confidence_proxy, na.rm = TRUE),
    avg_capacity_asset_process = mean(capacity_asset_process_proxy, na.rm = TRUE),
    avg_performance_outcome = mean(performance_outcome_proxy, na.rm = TRUE),
    avg_measurement_vulnerability = mean(measurement_vulnerability_proxy, na.rm = TRUE),
    avg_capacity = mean(capacity_index, na.rm = TRUE),
    avg_assets = mean(asset_index, na.rm = TRUE),
    avg_process = mean(process_index, na.rm = TRUE),
    avg_outcome = mean(outcome_index, na.rm = TRUE),
    avg_service_continuity = mean(service_continuity_index, na.rm = TRUE),
    avg_recovery_performance = mean(recovery_performance_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_distributional_inequality = mean(distributional_inequality_index, na.rm = TRUE),
    avg_measurement_uncertainty = mean(measurement_uncertainty_index, na.rm = TRUE),
    avg_data_quality_gap = mean(data_quality_gap_index, na.rm = TRUE),
    avg_measurement_gap = mean(measurement_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_equity_adjusted_resilience))

system_type_summary <- indicator_df %>%
  group_by(system_type) %>%
  summarise(
    avg_equity_adjusted_resilience = mean(equity_adjusted_resilience_proxy, na.rm = TRUE),
    avg_measured_resilience = mean(measured_resilience_proxy, na.rm = TRUE),
    avg_indicator_confidence = mean(indicator_confidence_proxy, na.rm = TRUE),
    avg_capacity_asset_process = mean(capacity_asset_process_proxy, na.rm = TRUE),
    avg_performance_outcome = mean(performance_outcome_proxy, na.rm = TRUE),
    avg_measurement_vulnerability = mean(measurement_vulnerability_proxy, na.rm = TRUE),
    avg_capacity = mean(capacity_index, na.rm = TRUE),
    avg_assets = mean(asset_index, na.rm = TRUE),
    avg_process = mean(process_index, na.rm = TRUE),
    avg_outcome = mean(outcome_index, na.rm = TRUE),
    avg_service_continuity = mean(service_continuity_index, na.rm = TRUE),
    avg_recovery_performance = mean(recovery_performance_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_distributional_inequality = mean(distributional_inequality_index, na.rm = TRUE),
    avg_measurement_uncertainty = mean(measurement_uncertainty_index, na.rm = TRUE),
    avg_data_quality_gap = mean(data_quality_gap_index, na.rm = TRUE),
    avg_measurement_gap = mean(measurement_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_equity_adjusted_resilience))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_type_summary, system_output_file)

cat("Resilience indicator jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nResilience indicator system-type summary exported to:", system_output_file, "\n")
print(system_type_summary)

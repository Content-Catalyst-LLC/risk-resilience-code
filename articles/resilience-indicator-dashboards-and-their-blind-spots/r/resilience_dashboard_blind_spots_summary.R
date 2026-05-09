library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_dashboard_blind_spots_panel.csv"
jurisdiction_output_file <- "../outputs/dashboard_blind_spots_jurisdiction_summary.csv"
type_output_file <- "../outputs/dashboard_blind_spots_type_summary.csv"

dashboard_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "dashboard_name",
  "jurisdiction",
  "dashboard_type",
  "indicator_coverage_index",
  "dashboard_usability_index",
  "data_quality_index",
  "update_frequency_index",
  "disaggregation_strength_index",
  "equity_visibility_index",
  "uncertainty_transparency_index",
  "action_linkage_index",
  "community_validation_index",
  "governance_accountability_index",
  "threshold_clarity_index",
  "stress_performance_integration_index",
  "false_precision_risk_index",
  "proxy_dependence_index",
  "missing_data_risk_index",
  "aggregation_loss_index",
  "scale_boundary_error_index",
  "dashboard_theater_risk_index",
  "blind_spot_severity_index"
)

missing_cols <- setdiff(required_cols, names(dashboard_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(dashboard_df)[grepl("_index$", names(dashboard_df))]

invalid_index_cols <- index_cols[
  vapply(
    dashboard_df[index_cols],
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

dashboard_df <- dashboard_df %>%
  mutate(
    dashboard_strength_proxy = (
      indicator_coverage_index +
        dashboard_usability_index +
        data_quality_index +
        update_frequency_index +
        disaggregation_strength_index +
        equity_visibility_index +
        uncertainty_transparency_index +
        action_linkage_index +
        community_validation_index +
        governance_accountability_index +
        threshold_clarity_index +
        stress_performance_integration_index
    ) / 12,
    blind_spot_risk_proxy = (
      false_precision_risk_index +
        proxy_dependence_index +
        missing_data_risk_index +
        aggregation_loss_index +
        scale_boundary_error_index +
        dashboard_theater_risk_index +
        blind_spot_severity_index
    ) / 7,
    actionability_proxy = (
      action_linkage_index +
        governance_accountability_index +
        threshold_clarity_index +
        stress_performance_integration_index +
        update_frequency_index +
        dashboard_usability_index
    ) / 6,
    equity_adjusted_dashboard_reliability_proxy = (
      dashboard_strength_proxy +
        actionability_proxy +
        (1 - blind_spot_risk_proxy) +
        equity_visibility_index +
        community_validation_index
    ) / 5,
    dashboard_reliability_gap = dashboard_strength_proxy - blind_spot_risk_proxy,
    dashboard_band = case_when(
      equity_adjusted_dashboard_reliability_proxy >= 0.75 ~ "Strong resilience dashboard reliability",
      equity_adjusted_dashboard_reliability_proxy >= 0.55 ~ "Moderate resilience dashboard reliability",
      equity_adjusted_dashboard_reliability_proxy >= 0.35 ~ "Limited resilience dashboard reliability",
      TRUE ~ "Weak resilience dashboard reliability"
    )
  )

jurisdiction_summary <- dashboard_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_equity_adjusted_dashboard_reliability = mean(equity_adjusted_dashboard_reliability_proxy, na.rm = TRUE),
    avg_dashboard_strength = mean(dashboard_strength_proxy, na.rm = TRUE),
    avg_blind_spot_risk = mean(blind_spot_risk_proxy, na.rm = TRUE),
    avg_actionability = mean(actionability_proxy, na.rm = TRUE),
    avg_indicator_coverage = mean(indicator_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_disaggregation_strength = mean(disaggregation_strength_index, na.rm = TRUE),
    avg_equity_visibility = mean(equity_visibility_index, na.rm = TRUE),
    avg_uncertainty_transparency = mean(uncertainty_transparency_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_false_precision_risk = mean(false_precision_risk_index, na.rm = TRUE),
    avg_proxy_dependence = mean(proxy_dependence_index, na.rm = TRUE),
    avg_missing_data_risk = mean(missing_data_risk_index, na.rm = TRUE),
    avg_aggregation_loss = mean(aggregation_loss_index, na.rm = TRUE),
    avg_dashboard_theater_risk = mean(dashboard_theater_risk_index, na.rm = TRUE),
    avg_dashboard_reliability_gap = mean(dashboard_reliability_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_equity_adjusted_dashboard_reliability))

type_summary <- dashboard_df %>%
  group_by(dashboard_type) %>%
  summarise(
    avg_equity_adjusted_dashboard_reliability = mean(equity_adjusted_dashboard_reliability_proxy, na.rm = TRUE),
    avg_dashboard_strength = mean(dashboard_strength_proxy, na.rm = TRUE),
    avg_blind_spot_risk = mean(blind_spot_risk_proxy, na.rm = TRUE),
    avg_actionability = mean(actionability_proxy, na.rm = TRUE),
    avg_indicator_coverage = mean(indicator_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_disaggregation_strength = mean(disaggregation_strength_index, na.rm = TRUE),
    avg_equity_visibility = mean(equity_visibility_index, na.rm = TRUE),
    avg_uncertainty_transparency = mean(uncertainty_transparency_index, na.rm = TRUE),
    avg_action_linkage = mean(action_linkage_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_false_precision_risk = mean(false_precision_risk_index, na.rm = TRUE),
    avg_proxy_dependence = mean(proxy_dependence_index, na.rm = TRUE),
    avg_missing_data_risk = mean(missing_data_risk_index, na.rm = TRUE),
    avg_aggregation_loss = mean(aggregation_loss_index, na.rm = TRUE),
    avg_dashboard_theater_risk = mean(dashboard_theater_risk_index, na.rm = TRUE),
    avg_dashboard_reliability_gap = mean(dashboard_reliability_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_equity_adjusted_dashboard_reliability))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(type_summary, type_output_file)

cat("Dashboard blind-spot jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nDashboard blind-spot type summary exported to:", type_output_file, "\n")
print(type_summary)

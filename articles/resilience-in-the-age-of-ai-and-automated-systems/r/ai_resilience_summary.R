library(readr)
library(dplyr)

input_file <- "../data/raw/ai_resilience_system_panel.csv"
sector_output_file <- "../outputs/ai_resilience_sector_summary.csv"
use_case_output_file <- "../outputs/ai_resilience_use_case_summary.csv"

ai_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "ai_use_case",
  "model_reliability_index",
  "monitoring_capacity_index",
  "oversight_capacity_index",
  "governance_strength_index",
  "explainability_index",
  "contestability_index",
  "fallback_capacity_index",
  "data_quality_index",
  "bias_management_index",
  "privacy_protection_index",
  "cyber_resilience_index",
  "concentration_risk_index",
  "automation_dependence_index",
  "drift_risk_index",
  "opacity_risk_index",
  "public_accountability_index",
  "service_criticality_index"
)

missing_cols <- setdiff(required_cols, names(ai_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(ai_df)[grepl("_index$", names(ai_df))]

invalid_index_cols <- index_cols[
  vapply(
    ai_df[index_cols],
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

ai_df <- ai_df %>%
  mutate(
    ai_resilience_capacity_proxy = (
      model_reliability_index +
        monitoring_capacity_index +
        oversight_capacity_index +
        governance_strength_index +
        explainability_index +
        contestability_index +
        fallback_capacity_index +
        data_quality_index +
        bias_management_index +
        privacy_protection_index +
        cyber_resilience_index
    ) / 11,
    automation_fragility_proxy = (
      concentration_risk_index +
        automation_dependence_index +
        drift_risk_index +
        opacity_risk_index +
        (1 - fallback_capacity_index) +
        (1 - monitoring_capacity_index) +
        (1 - oversight_capacity_index) +
        (1 - contestability_index) +
        (1 - public_accountability_index)
    ) / 9,
    resilience_adjusted_ai_risk_proxy = (
      automation_fragility_proxy +
        (1 - ai_resilience_capacity_proxy) +
        service_criticality_index +
        concentration_risk_index +
        drift_risk_index +
        opacity_risk_index +
        (1 - public_accountability_index)
    ) / 7,
    resilience_gap = ai_resilience_capacity_proxy - automation_fragility_proxy,
    risk_band = case_when(
      resilience_adjusted_ai_risk_proxy >= 0.75 ~ "Extreme AI resilience risk",
      resilience_adjusted_ai_risk_proxy >= 0.55 ~ "High AI resilience risk",
      resilience_adjusted_ai_risk_proxy >= 0.35 ~ "Moderate AI resilience risk",
      TRUE ~ "Lower AI resilience risk"
    )
  )

sector_summary <- ai_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_adjusted_ai_risk = mean(resilience_adjusted_ai_risk_proxy, na.rm = TRUE),
    avg_ai_resilience_capacity = mean(ai_resilience_capacity_proxy, na.rm = TRUE),
    avg_automation_fragility = mean(automation_fragility_proxy, na.rm = TRUE),
    avg_model_reliability = mean(model_reliability_index, na.rm = TRUE),
    avg_monitoring_capacity = mean(monitoring_capacity_index, na.rm = TRUE),
    avg_oversight_capacity = mean(oversight_capacity_index, na.rm = TRUE),
    avg_governance_strength = mean(governance_strength_index, na.rm = TRUE),
    avg_explainability = mean(explainability_index, na.rm = TRUE),
    avg_contestability = mean(contestability_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    avg_concentration_risk = mean(concentration_risk_index, na.rm = TRUE),
    avg_automation_dependence = mean(automation_dependence_index, na.rm = TRUE),
    avg_drift_risk = mean(drift_risk_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    sector_risk_band = case_when(
      avg_resilience_adjusted_ai_risk >= 0.75 ~ "Extreme AI resilience risk",
      avg_resilience_adjusted_ai_risk >= 0.55 ~ "High AI resilience risk",
      avg_resilience_adjusted_ai_risk >= 0.35 ~ "Moderate AI resilience risk",
      TRUE ~ "Lower AI resilience risk"
    )
  ) %>%
  arrange(desc(avg_resilience_adjusted_ai_risk))

use_case_summary <- ai_df %>%
  group_by(ai_use_case) %>%
  summarise(
    avg_resilience_adjusted_ai_risk = mean(resilience_adjusted_ai_risk_proxy, na.rm = TRUE),
    avg_ai_resilience_capacity = mean(ai_resilience_capacity_proxy, na.rm = TRUE),
    avg_automation_fragility = mean(automation_fragility_proxy, na.rm = TRUE),
    avg_model_reliability = mean(model_reliability_index, na.rm = TRUE),
    avg_monitoring_capacity = mean(monitoring_capacity_index, na.rm = TRUE),
    avg_oversight_capacity = mean(oversight_capacity_index, na.rm = TRUE),
    avg_governance_strength = mean(governance_strength_index, na.rm = TRUE),
    avg_explainability = mean(explainability_index, na.rm = TRUE),
    avg_contestability = mean(contestability_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    avg_concentration_risk = mean(concentration_risk_index, na.rm = TRUE),
    avg_automation_dependence = mean(automation_dependence_index, na.rm = TRUE),
    avg_drift_risk = mean(drift_risk_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_ai_risk))

write_csv(sector_summary, sector_output_file)
write_csv(use_case_summary, use_case_output_file)

cat("AI resilience sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nAI resilience use-case summary exported to:", use_case_output_file, "\n")
print(use_case_summary)

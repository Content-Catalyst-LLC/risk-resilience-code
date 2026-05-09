library(readr)
library(dplyr)

input_file <- "../data/raw/ai_algorithmic_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/ai_algorithmic_resilience_jurisdiction_summary.csv"
domain_output_file <- "../outputs/ai_algorithmic_resilience_domain_summary.csv"

ai_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "jurisdiction",
  "system_domain",
  "model_capability_index",
  "institutional_governance_index",
  "data_quality_index",
  "human_oversight_index",
  "auditability_index",
  "system_robustness_index",
  "equity_testing_index",
  "security_control_index",
  "fallback_capacity_index",
  "public_contestability_index",
  "monitoring_maturity_index",
  "incident_response_index",
  "vendor_accountability_index",
  "opacity_risk_index",
  "bias_severity_index",
  "model_drift_risk_index",
  "automation_dependency_index",
  "vendor_concentration_risk_index",
  "cyber_exposure_index",
  "legitimacy_risk_index"
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
    ai_resilience_capability_proxy = (
      model_capability_index +
        data_quality_index +
        system_robustness_index +
        monitoring_maturity_index +
        incident_response_index +
        security_control_index +
        fallback_capacity_index
    ) / 7,
    algorithmic_governance_proxy = (
      institutional_governance_index +
        human_oversight_index +
        auditability_index +
        equity_testing_index +
        public_contestability_index +
        vendor_accountability_index +
        monitoring_maturity_index
    ) / 7,
    algorithmic_fragility_pressure_proxy = (
      opacity_risk_index +
        bias_severity_index +
        model_drift_risk_index +
        automation_dependency_index +
        vendor_concentration_risk_index +
        cyber_exposure_index +
        legitimacy_risk_index
    ) / 7,
    legitimacy_adjusted_ai_resilience_proxy = (
      ai_resilience_capability_proxy +
        algorithmic_governance_proxy +
        public_contestability_index +
        human_oversight_index +
        equity_testing_index +
        (1 - algorithmic_fragility_pressure_proxy)
    ) / 6,
    algorithmic_resilience_gap = legitimacy_adjusted_ai_resilience_proxy -
      algorithmic_fragility_pressure_proxy,
    resilience_band = case_when(
      legitimacy_adjusted_ai_resilience_proxy >= 0.75 ~ "Strong algorithmic resilience readiness",
      legitimacy_adjusted_ai_resilience_proxy >= 0.55 ~ "Moderate algorithmic resilience readiness",
      legitimacy_adjusted_ai_resilience_proxy >= 0.35 ~ "Limited algorithmic resilience readiness",
      TRUE ~ "Weak algorithmic resilience readiness"
    )
  )

jurisdiction_summary <- ai_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_legitimacy_adjusted_ai_resilience = mean(legitimacy_adjusted_ai_resilience_proxy, na.rm = TRUE),
    avg_ai_resilience_capability = mean(ai_resilience_capability_proxy, na.rm = TRUE),
    avg_algorithmic_governance = mean(algorithmic_governance_proxy, na.rm = TRUE),
    avg_algorithmic_fragility_pressure = mean(algorithmic_fragility_pressure_proxy, na.rm = TRUE),
    avg_model_capability = mean(model_capability_index, na.rm = TRUE),
    avg_human_oversight = mean(human_oversight_index, na.rm = TRUE),
    avg_auditability = mean(auditability_index, na.rm = TRUE),
    avg_equity_testing = mean(equity_testing_index, na.rm = TRUE),
    avg_security_control = mean(security_control_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    avg_public_contestability = mean(public_contestability_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_bias_severity = mean(bias_severity_index, na.rm = TRUE),
    avg_model_drift_risk = mean(model_drift_risk_index, na.rm = TRUE),
    avg_automation_dependency = mean(automation_dependency_index, na.rm = TRUE),
    avg_cyber_exposure = mean(cyber_exposure_index, na.rm = TRUE),
    avg_algorithmic_resilience_gap = mean(algorithmic_resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_legitimacy_adjusted_ai_resilience))

domain_summary <- ai_df %>%
  group_by(system_domain) %>%
  summarise(
    avg_legitimacy_adjusted_ai_resilience = mean(legitimacy_adjusted_ai_resilience_proxy, na.rm = TRUE),
    avg_ai_resilience_capability = mean(ai_resilience_capability_proxy, na.rm = TRUE),
    avg_algorithmic_governance = mean(algorithmic_governance_proxy, na.rm = TRUE),
    avg_algorithmic_fragility_pressure = mean(algorithmic_fragility_pressure_proxy, na.rm = TRUE),
    avg_model_capability = mean(model_capability_index, na.rm = TRUE),
    avg_human_oversight = mean(human_oversight_index, na.rm = TRUE),
    avg_auditability = mean(auditability_index, na.rm = TRUE),
    avg_equity_testing = mean(equity_testing_index, na.rm = TRUE),
    avg_security_control = mean(security_control_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    avg_public_contestability = mean(public_contestability_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_bias_severity = mean(bias_severity_index, na.rm = TRUE),
    avg_model_drift_risk = mean(model_drift_risk_index, na.rm = TRUE),
    avg_automation_dependency = mean(automation_dependency_index, na.rm = TRUE),
    avg_cyber_exposure = mean(cyber_exposure_index, na.rm = TRUE),
    avg_algorithmic_resilience_gap = mean(algorithmic_resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_algorithmic_fragility_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("AI algorithmic resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nAI algorithmic resilience domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

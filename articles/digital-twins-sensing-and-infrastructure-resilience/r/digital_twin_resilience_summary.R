library(readr)
library(dplyr)

input_file <- "../data/raw/digital_twin_infrastructure_panel.csv"
sector_output_file <- "../outputs/digital_twin_sector_summary.csv"
infrastructure_output_file <- "../outputs/digital_twin_infrastructure_type_summary.csv"

twin_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "infrastructure_type",
  "sensing_coverage_index",
  "data_quality_index",
  "data_timeliness_index",
  "model_validation_index",
  "decision_integration_index",
  "dependency_visibility_index",
  "predictive_maintenance_usefulness_index",
  "climate_adaptation_usefulness_index",
  "service_continuity_relevance_index",
  "cyber_risk_index",
  "platform_dependency_index",
  "model_uncertainty_index",
  "equity_coverage_index",
  "governance_capacity_index",
  "public_accountability_index"
)

missing_cols <- setdiff(required_cols, names(twin_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(twin_df)[grepl("_index$", names(twin_df))]

invalid_index_cols <- index_cols[
  vapply(
    twin_df[index_cols],
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

twin_df <- twin_df %>%
  mutate(
    resilience_contribution_proxy = (
      sensing_coverage_index +
        data_quality_index +
        data_timeliness_index +
        model_validation_index +
        decision_integration_index +
        dependency_visibility_index +
        predictive_maintenance_usefulness_index +
        climate_adaptation_usefulness_index +
        equity_coverage_index +
        governance_capacity_index
    ) / 10,
    implementation_risk_proxy = (
      cyber_risk_index +
        platform_dependency_index +
        model_uncertainty_index +
        (1 - model_validation_index) +
        (1 - data_quality_index) +
        (1 - governance_capacity_index) +
        (1 - public_accountability_index) +
        (1 - equity_coverage_index)
    ) / 8,
    resilience_readiness_proxy = (
      resilience_contribution_proxy +
        (1 - implementation_risk_proxy) +
        service_continuity_relevance_index +
        governance_capacity_index +
        public_accountability_index
    ) / 5,
    resilience_gap = resilience_contribution_proxy - implementation_risk_proxy,
    readiness_band = case_when(
      resilience_readiness_proxy >= 0.75 ~ "Strong digital twin resilience readiness",
      resilience_readiness_proxy >= 0.55 ~ "Moderate digital twin resilience readiness",
      resilience_readiness_proxy >= 0.35 ~ "Limited digital twin resilience readiness",
      TRUE ~ "Weak digital twin resilience readiness"
    )
  )

sector_summary <- twin_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_readiness_proxy = mean(resilience_readiness_proxy, na.rm = TRUE),
    avg_resilience_contribution_proxy = mean(resilience_contribution_proxy, na.rm = TRUE),
    avg_implementation_risk_proxy = mean(implementation_risk_proxy, na.rm = TRUE),
    avg_sensing_coverage = mean(sensing_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_model_validation = mean(model_validation_index, na.rm = TRUE),
    avg_decision_integration = mean(decision_integration_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_predictive_maintenance_usefulness = mean(predictive_maintenance_usefulness_index, na.rm = TRUE),
    avg_climate_adaptation_usefulness = mean(climate_adaptation_usefulness_index, na.rm = TRUE),
    avg_cyber_risk = mean(cyber_risk_index, na.rm = TRUE),
    avg_equity_coverage = mean(equity_coverage_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    sector_readiness_band = case_when(
      avg_resilience_readiness_proxy >= 0.75 ~ "Strong digital twin resilience readiness",
      avg_resilience_readiness_proxy >= 0.55 ~ "Moderate digital twin resilience readiness",
      avg_resilience_readiness_proxy >= 0.35 ~ "Limited digital twin resilience readiness",
      TRUE ~ "Weak digital twin resilience readiness"
    )
  ) %>%
  arrange(desc(avg_resilience_readiness_proxy))

infrastructure_type_summary <- twin_df %>%
  group_by(infrastructure_type) %>%
  summarise(
    avg_resilience_readiness_proxy = mean(resilience_readiness_proxy, na.rm = TRUE),
    avg_resilience_contribution_proxy = mean(resilience_contribution_proxy, na.rm = TRUE),
    avg_implementation_risk_proxy = mean(implementation_risk_proxy, na.rm = TRUE),
    avg_sensing_coverage = mean(sensing_coverage_index, na.rm = TRUE),
    avg_data_quality = mean(data_quality_index, na.rm = TRUE),
    avg_model_validation = mean(model_validation_index, na.rm = TRUE),
    avg_decision_integration = mean(decision_integration_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_predictive_maintenance_usefulness = mean(predictive_maintenance_usefulness_index, na.rm = TRUE),
    avg_climate_adaptation_usefulness = mean(climate_adaptation_usefulness_index, na.rm = TRUE),
    avg_cyber_risk = mean(cyber_risk_index, na.rm = TRUE),
    avg_equity_coverage = mean(equity_coverage_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_readiness_proxy))

write_csv(sector_summary, sector_output_file)
write_csv(infrastructure_type_summary, infrastructure_output_file)

cat("Digital twin sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nDigital twin infrastructure-type summary exported to:", infrastructure_output_file, "\n")
print(infrastructure_type_summary)

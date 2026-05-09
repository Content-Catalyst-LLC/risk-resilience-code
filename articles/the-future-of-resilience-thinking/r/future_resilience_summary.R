library(readr)
library(dplyr)

input_file <- "../data/raw/future_resilience_framework_panel.csv"
jurisdiction_output_file <- "../outputs/future_resilience_jurisdiction_summary.csv"
domain_output_file <- "../outputs/future_resilience_domain_summary.csv"

future_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "strategy_name",
  "jurisdiction",
  "strategy_domain",
  "systemic_risk_capacity_index",
  "governance_integration_index",
  "justice_transformation_index",
  "regenerative_capacity_index",
  "local_capability_index",
  "technological_accountability_index",
  "planetary_alignment_index",
  "investment_readiness_index",
  "data_accountability_index",
  "learning_capacity_index",
  "fragmentation_risk_index",
  "maladaptation_risk_index",
  "inequality_risk_index",
  "ecological_overshoot_risk_index",
  "technological_dependency_risk_index",
  "conceptual_vagueness_index"
)

missing_cols <- setdiff(required_cols, names(future_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(future_df)[grepl("_index$", names(future_df))]

invalid_index_cols <- index_cols[
  vapply(
    future_df[index_cols],
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

future_df <- future_df %>%
  mutate(
    future_resilience_capacity_proxy = (
      systemic_risk_capacity_index +
        governance_integration_index +
        justice_transformation_index +
        regenerative_capacity_index +
        local_capability_index +
        technological_accountability_index +
        planetary_alignment_index +
        investment_readiness_index +
        data_accountability_index +
        learning_capacity_index
    ) / 10,
    future_fragility_pressure_proxy = (
      fragmentation_risk_index +
        maladaptation_risk_index +
        inequality_risk_index +
        ecological_overshoot_risk_index +
        technological_dependency_risk_index +
        conceptual_vagueness_index
    ) / 6,
    conceptual_discipline_proxy = (
      (1 - conceptual_vagueness_index) +
        data_accountability_index +
        learning_capacity_index +
        governance_integration_index
    ) / 4,
    future_resilience_readiness_gap = future_resilience_capacity_proxy -
      future_fragility_pressure_proxy,
    resilience_future_band = case_when(
      future_resilience_capacity_proxy >= 0.75 ~ "Strong future-oriented resilience framework",
      future_resilience_capacity_proxy >= 0.55 ~ "Moderate future-oriented resilience framework",
      future_resilience_capacity_proxy >= 0.35 ~ "Limited future-oriented resilience framework",
      TRUE ~ "Weak future-oriented resilience framework"
    )
  )

jurisdiction_summary <- future_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_future_resilience_capacity = mean(future_resilience_capacity_proxy, na.rm = TRUE),
    avg_future_fragility_pressure = mean(future_fragility_pressure_proxy, na.rm = TRUE),
    avg_future_resilience_readiness_gap = mean(future_resilience_readiness_gap, na.rm = TRUE),
    avg_conceptual_discipline = mean(conceptual_discipline_proxy, na.rm = TRUE),
    avg_systemic_risk_capacity = mean(systemic_risk_capacity_index, na.rm = TRUE),
    avg_governance_integration = mean(governance_integration_index, na.rm = TRUE),
    avg_justice_transformation = mean(justice_transformation_index, na.rm = TRUE),
    avg_regenerative_capacity = mean(regenerative_capacity_index, na.rm = TRUE),
    avg_local_capability = mean(local_capability_index, na.rm = TRUE),
    avg_technological_accountability = mean(technological_accountability_index, na.rm = TRUE),
    avg_planetary_alignment = mean(planetary_alignment_index, na.rm = TRUE),
    avg_investment_readiness = mean(investment_readiness_index, na.rm = TRUE),
    avg_data_accountability = mean(data_accountability_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_inequality_risk = mean(inequality_risk_index, na.rm = TRUE),
    avg_ecological_overshoot_risk = mean(ecological_overshoot_risk_index, na.rm = TRUE),
    avg_technological_dependency_risk = mean(technological_dependency_risk_index, na.rm = TRUE),
    avg_conceptual_vagueness = mean(conceptual_vagueness_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_future_resilience_readiness_gap))

domain_summary <- future_df %>%
  group_by(strategy_domain) %>%
  summarise(
    avg_future_resilience_capacity = mean(future_resilience_capacity_proxy, na.rm = TRUE),
    avg_future_fragility_pressure = mean(future_fragility_pressure_proxy, na.rm = TRUE),
    avg_future_resilience_readiness_gap = mean(future_resilience_readiness_gap, na.rm = TRUE),
    avg_conceptual_discipline = mean(conceptual_discipline_proxy, na.rm = TRUE),
    avg_systemic_risk_capacity = mean(systemic_risk_capacity_index, na.rm = TRUE),
    avg_governance_integration = mean(governance_integration_index, na.rm = TRUE),
    avg_justice_transformation = mean(justice_transformation_index, na.rm = TRUE),
    avg_regenerative_capacity = mean(regenerative_capacity_index, na.rm = TRUE),
    avg_local_capability = mean(local_capability_index, na.rm = TRUE),
    avg_technological_accountability = mean(technological_accountability_index, na.rm = TRUE),
    avg_planetary_alignment = mean(planetary_alignment_index, na.rm = TRUE),
    avg_investment_readiness = mean(investment_readiness_index, na.rm = TRUE),
    avg_data_accountability = mean(data_accountability_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_inequality_risk = mean(inequality_risk_index, na.rm = TRUE),
    avg_ecological_overshoot_risk = mean(ecological_overshoot_risk_index, na.rm = TRUE),
    avg_technological_dependency_risk = mean(technological_dependency_risk_index, na.rm = TRUE),
    avg_conceptual_vagueness = mean(conceptual_vagueness_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_future_fragility_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Future resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nFuture resilience domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

library(readr)
library(dplyr)

input_file <- "../data/raw/public_institutional_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/public_institutional_resilience_jurisdiction_summary.csv"
domain_output_file <- "../outputs/public_institutional_resilience_domain_summary.csv"

inst_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "institution_name",
  "jurisdiction",
  "institution_type",
  "primary_service_domain",
  "anticipatory_foresight_index",
  "continuity_operations_index",
  "administrative_capacity_index",
  "coordination_capacity_index",
  "risk_informed_finance_index",
  "procurement_resilience_index",
  "digital_fallback_index",
  "public_legitimacy_index",
  "justice_service_equity_index",
  "learning_adaptation_index",
  "fragmentation_risk_index",
  "underinvestment_risk_index",
  "staffing_fragility_index",
  "digital_dependency_risk_index",
  "procurement_vulnerability_index",
  "accountability_gap_index"
)

missing_cols <- setdiff(required_cols, names(inst_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(inst_df)[grepl("_index$", names(inst_df))]

invalid_index_cols <- index_cols[
  vapply(
    inst_df[index_cols],
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

inst_df <- inst_df %>%
  mutate(
    institutional_resilience_capacity_proxy = (
      anticipatory_foresight_index +
        continuity_operations_index +
        administrative_capacity_index +
        coordination_capacity_index +
        risk_informed_finance_index +
        procurement_resilience_index +
        digital_fallback_index +
        public_legitimacy_index +
        justice_service_equity_index +
        learning_adaptation_index
    ) / 10,
    institutional_fragility_pressure_proxy = (
      fragmentation_risk_index +
        underinvestment_risk_index +
        staffing_fragility_index +
        digital_dependency_risk_index +
        procurement_vulnerability_index +
        accountability_gap_index
    ) / 6,
    legitimacy_adjusted_resilience_proxy = (
      institutional_resilience_capacity_proxy +
        public_legitimacy_index +
        justice_service_equity_index +
        (1 - accountability_gap_index)
    ) / 4,
    institutional_resilience_gap = legitimacy_adjusted_resilience_proxy -
      institutional_fragility_pressure_proxy,
    resilience_band = case_when(
      legitimacy_adjusted_resilience_proxy >= 0.75 ~ "Strong public institutional resilience",
      legitimacy_adjusted_resilience_proxy >= 0.55 ~ "Moderate public institutional resilience",
      legitimacy_adjusted_resilience_proxy >= 0.35 ~ "Limited public institutional resilience",
      TRUE ~ "Weak public institutional resilience"
    )
  )

jurisdiction_summary <- inst_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_legitimacy_adjusted_resilience = mean(legitimacy_adjusted_resilience_proxy, na.rm = TRUE),
    avg_institutional_resilience_capacity = mean(institutional_resilience_capacity_proxy, na.rm = TRUE),
    avg_institutional_fragility_pressure = mean(institutional_fragility_pressure_proxy, na.rm = TRUE),
    avg_institutional_resilience_gap = mean(institutional_resilience_gap, na.rm = TRUE),
    avg_anticipatory_foresight = mean(anticipatory_foresight_index, na.rm = TRUE),
    avg_continuity_operations = mean(continuity_operations_index, na.rm = TRUE),
    avg_administrative_capacity = mean(administrative_capacity_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_risk_informed_finance = mean(risk_informed_finance_index, na.rm = TRUE),
    avg_procurement_resilience = mean(procurement_resilience_index, na.rm = TRUE),
    avg_digital_fallback = mean(digital_fallback_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_justice_service_equity = mean(justice_service_equity_index, na.rm = TRUE),
    avg_learning_adaptation = mean(learning_adaptation_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_underinvestment_risk = mean(underinvestment_risk_index, na.rm = TRUE),
    avg_staffing_fragility = mean(staffing_fragility_index, na.rm = TRUE),
    avg_digital_dependency_risk = mean(digital_dependency_risk_index, na.rm = TRUE),
    avg_procurement_vulnerability = mean(procurement_vulnerability_index, na.rm = TRUE),
    avg_accountability_gap = mean(accountability_gap_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_institutional_resilience_gap))

domain_summary <- inst_df %>%
  group_by(primary_service_domain) %>%
  summarise(
    avg_legitimacy_adjusted_resilience = mean(legitimacy_adjusted_resilience_proxy, na.rm = TRUE),
    avg_institutional_resilience_capacity = mean(institutional_resilience_capacity_proxy, na.rm = TRUE),
    avg_institutional_fragility_pressure = mean(institutional_fragility_pressure_proxy, na.rm = TRUE),
    avg_institutional_resilience_gap = mean(institutional_resilience_gap, na.rm = TRUE),
    avg_anticipatory_foresight = mean(anticipatory_foresight_index, na.rm = TRUE),
    avg_continuity_operations = mean(continuity_operations_index, na.rm = TRUE),
    avg_administrative_capacity = mean(administrative_capacity_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_risk_informed_finance = mean(risk_informed_finance_index, na.rm = TRUE),
    avg_procurement_resilience = mean(procurement_resilience_index, na.rm = TRUE),
    avg_digital_fallback = mean(digital_fallback_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_justice_service_equity = mean(justice_service_equity_index, na.rm = TRUE),
    avg_learning_adaptation = mean(learning_adaptation_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_underinvestment_risk = mean(underinvestment_risk_index, na.rm = TRUE),
    avg_staffing_fragility = mean(staffing_fragility_index, na.rm = TRUE),
    avg_digital_dependency_risk = mean(digital_dependency_risk_index, na.rm = TRUE),
    avg_procurement_vulnerability = mean(procurement_vulnerability_index, na.rm = TRUE),
    avg_accountability_gap = mean(accountability_gap_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_institutional_fragility_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Public institutional resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nPublic institutional resilience domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

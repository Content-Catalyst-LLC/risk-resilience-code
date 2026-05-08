library(readr)
library(dplyr)

input_file <- "../data/raw/public_institution_stress_test_panel.csv"
jurisdiction_output_file <- "../outputs/public_institution_stress_jurisdiction_summary.csv"
function_output_file <- "../outputs/public_institution_stress_function_summary.csv"

stress_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "institution_or_system",
  "jurisdiction",
  "public_function",
  "essential_function_clarity_index",
  "capacity_margin_index",
  "dependency_visibility_index",
  "workforce_resilience_index",
  "digital_resilience_index",
  "legal_authority_clarity_index",
  "coordination_capacity_index",
  "equity_protection_index",
  "public_trust_index",
  "recovery_capacity_index",
  "backup_systems_index",
  "mutual_aid_capacity_index",
  "fiscal_reserve_capacity_index",
  "learning_capacity_index",
  "accountability_mechanism_index",
  "overload_pressure_index",
  "institutional_fragmentation_index",
  "hidden_fragility_index",
  "vendor_dependency_index",
  "compound_stress_exposure_index"
)

missing_cols <- setdiff(required_cols, names(stress_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(stress_df)[grepl("_index$", names(stress_df))]

invalid_index_cols <- index_cols[
  vapply(
    stress_df[index_cols],
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

stress_df <- stress_df %>%
  mutate(
    stress_readiness_proxy = (
      essential_function_clarity_index +
        capacity_margin_index +
        dependency_visibility_index +
        workforce_resilience_index +
        digital_resilience_index +
        legal_authority_clarity_index +
        coordination_capacity_index +
        equity_protection_index +
        public_trust_index +
        recovery_capacity_index +
        learning_capacity_index +
        accountability_mechanism_index
    ) / 12,
    stress_vulnerability_proxy = (
      overload_pressure_index +
        institutional_fragmentation_index +
        hidden_fragility_index +
        vendor_dependency_index +
        compound_stress_exposure_index +
        (1 - capacity_margin_index) +
        (1 - dependency_visibility_index) +
        (1 - digital_resilience_index) +
        (1 - workforce_resilience_index) +
        (1 - public_trust_index)
    ) / 10,
    institutional_recovery_proxy = (
      recovery_capacity_index +
        backup_systems_index +
        mutual_aid_capacity_index +
        fiscal_reserve_capacity_index +
        learning_capacity_index +
        accountability_mechanism_index +
        coordination_capacity_index
    ) / 7,
    resilience_adjusted_stress_risk_proxy = (
      stress_vulnerability_proxy +
        (1 - stress_readiness_proxy) +
        (1 - institutional_recovery_proxy) +
        compound_stress_exposure_index +
        (1 - equity_protection_index)
    ) / 5,
    readiness_gap = stress_readiness_proxy - stress_vulnerability_proxy,
    risk_band = case_when(
      resilience_adjusted_stress_risk_proxy >= 0.75 ~ "Extreme public-institution stress risk",
      resilience_adjusted_stress_risk_proxy >= 0.55 ~ "High public-institution stress risk",
      resilience_adjusted_stress_risk_proxy >= 0.35 ~ "Moderate public-institution stress risk",
      TRUE ~ "Lower public-institution stress risk"
    )
  )

jurisdiction_summary <- stress_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_resilience_adjusted_stress_risk = mean(resilience_adjusted_stress_risk_proxy, na.rm = TRUE),
    avg_stress_readiness = mean(stress_readiness_proxy, na.rm = TRUE),
    avg_stress_vulnerability = mean(stress_vulnerability_proxy, na.rm = TRUE),
    avg_institutional_recovery = mean(institutional_recovery_proxy, na.rm = TRUE),
    avg_essential_function_clarity = mean(essential_function_clarity_index, na.rm = TRUE),
    avg_capacity_margin = mean(capacity_margin_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_workforce_resilience = mean(workforce_resilience_index, na.rm = TRUE),
    avg_digital_resilience = mean(digital_resilience_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_public_trust = mean(public_trust_index, na.rm = TRUE),
    avg_overload_pressure = mean(overload_pressure_index, na.rm = TRUE),
    avg_hidden_fragility = mean(hidden_fragility_index, na.rm = TRUE),
    avg_vendor_dependency = mean(vendor_dependency_index, na.rm = TRUE),
    avg_readiness_gap = mean(readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    jurisdiction_risk_band = case_when(
      avg_resilience_adjusted_stress_risk >= 0.75 ~ "Extreme public-institution stress risk",
      avg_resilience_adjusted_stress_risk >= 0.55 ~ "High public-institution stress risk",
      avg_resilience_adjusted_stress_risk >= 0.35 ~ "Moderate public-institution stress risk",
      TRUE ~ "Lower public-institution stress risk"
    )
  ) %>%
  arrange(desc(avg_resilience_adjusted_stress_risk))

function_summary <- stress_df %>%
  group_by(public_function) %>%
  summarise(
    avg_resilience_adjusted_stress_risk = mean(resilience_adjusted_stress_risk_proxy, na.rm = TRUE),
    avg_stress_readiness = mean(stress_readiness_proxy, na.rm = TRUE),
    avg_stress_vulnerability = mean(stress_vulnerability_proxy, na.rm = TRUE),
    avg_institutional_recovery = mean(institutional_recovery_proxy, na.rm = TRUE),
    avg_essential_function_clarity = mean(essential_function_clarity_index, na.rm = TRUE),
    avg_capacity_margin = mean(capacity_margin_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_workforce_resilience = mean(workforce_resilience_index, na.rm = TRUE),
    avg_digital_resilience = mean(digital_resilience_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_public_trust = mean(public_trust_index, na.rm = TRUE),
    avg_overload_pressure = mean(overload_pressure_index, na.rm = TRUE),
    avg_hidden_fragility = mean(hidden_fragility_index, na.rm = TRUE),
    avg_vendor_dependency = mean(vendor_dependency_index, na.rm = TRUE),
    avg_readiness_gap = mean(readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_stress_risk))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(function_summary, function_output_file)

cat("Public-institution stress jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nPublic-institution stress function summary exported to:", function_output_file, "\n")
print(function_summary)

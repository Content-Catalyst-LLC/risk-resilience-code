library(readr)
library(dplyr)

input_file <- "../data/raw/regenerative_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/regenerative_resilience_jurisdiction_summary.csv"
system_output_file <- "../outputs/regenerative_resilience_system_type_summary.csv"

regen_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "jurisdiction",
  "system_type",
  "risk_management_capacity_index",
  "ecological_restoration_index",
  "social_capacity_index",
  "institutional_learning_index",
  "justice_orientation_index",
  "long_term_investment_index",
  "livelihood_viability_index",
  "ecological_function_index",
  "public_trust_index",
  "adaptive_governance_index",
  "community_participation_index",
  "regenerative_finance_index",
  "depletion_pressure_index",
  "maladaptation_risk_index",
  "extractive_pressure_index",
  "institutional_fatigue_index",
  "chronic_vulnerability_index",
  "recovery_only_bias_index"
)

missing_cols <- setdiff(required_cols, names(regen_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(regen_df)[grepl("_index$", names(regen_df))]

invalid_index_cols <- index_cols[
  vapply(
    regen_df[index_cols],
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

regen_df <- regen_df %>%
  mutate(
    defensive_risk_management_proxy = (
      risk_management_capacity_index +
        adaptive_governance_index +
        institutional_learning_index +
        public_trust_index +
        community_participation_index +
        long_term_investment_index
    ) / 6,
    regenerative_capacity_proxy = (
      ecological_restoration_index +
        ecological_function_index +
        social_capacity_index +
        institutional_learning_index +
        justice_orientation_index +
        livelihood_viability_index +
        long_term_investment_index +
        regenerative_finance_index
    ) / 8,
    depletion_pressure_proxy = (
      depletion_pressure_index +
        maladaptation_risk_index +
        extractive_pressure_index +
        institutional_fatigue_index +
        chronic_vulnerability_index +
        recovery_only_bias_index +
        (1 - ecological_function_index) +
        (1 - justice_orientation_index)
    ) / 8,
    regenerative_resilience_proxy = (
      regenerative_capacity_proxy +
        defensive_risk_management_proxy +
        (1 - depletion_pressure_proxy) +
        justice_orientation_index +
        ecological_function_index
    ) / 5,
    renewal_balance = regenerative_capacity_proxy - depletion_pressure_proxy,
    resilience_band = case_when(
      regenerative_resilience_proxy >= 0.75 ~ "Strong regenerative resilience",
      regenerative_resilience_proxy >= 0.55 ~ "Moderate regenerative resilience",
      regenerative_resilience_proxy >= 0.35 ~ "Limited regenerative resilience",
      TRUE ~ "Weak regenerative resilience"
    )
  )

jurisdiction_summary <- regen_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_regenerative_resilience = mean(regenerative_resilience_proxy, na.rm = TRUE),
    avg_defensive_risk_management = mean(defensive_risk_management_proxy, na.rm = TRUE),
    avg_regenerative_capacity = mean(regenerative_capacity_proxy, na.rm = TRUE),
    avg_depletion_pressure = mean(depletion_pressure_proxy, na.rm = TRUE),
    avg_ecological_restoration = mean(ecological_restoration_index, na.rm = TRUE),
    avg_ecological_function = mean(ecological_function_index, na.rm = TRUE),
    avg_social_capacity = mean(social_capacity_index, na.rm = TRUE),
    avg_institutional_learning = mean(institutional_learning_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_livelihood_viability = mean(livelihood_viability_index, na.rm = TRUE),
    avg_long_term_investment = mean(long_term_investment_index, na.rm = TRUE),
    avg_depletion_pressure_index = mean(depletion_pressure_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_institutional_fatigue = mean(institutional_fatigue_index, na.rm = TRUE),
    avg_renewal_balance = mean(renewal_balance, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_regenerative_resilience))

system_type_summary <- regen_df %>%
  group_by(system_type) %>%
  summarise(
    avg_regenerative_resilience = mean(regenerative_resilience_proxy, na.rm = TRUE),
    avg_defensive_risk_management = mean(defensive_risk_management_proxy, na.rm = TRUE),
    avg_regenerative_capacity = mean(regenerative_capacity_proxy, na.rm = TRUE),
    avg_depletion_pressure = mean(depletion_pressure_proxy, na.rm = TRUE),
    avg_ecological_restoration = mean(ecological_restoration_index, na.rm = TRUE),
    avg_ecological_function = mean(ecological_function_index, na.rm = TRUE),
    avg_social_capacity = mean(social_capacity_index, na.rm = TRUE),
    avg_institutional_learning = mean(institutional_learning_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_livelihood_viability = mean(livelihood_viability_index, na.rm = TRUE),
    avg_long_term_investment = mean(long_term_investment_index, na.rm = TRUE),
    avg_depletion_pressure_index = mean(depletion_pressure_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_institutional_fatigue = mean(institutional_fatigue_index, na.rm = TRUE),
    avg_renewal_balance = mean(renewal_balance, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_regenerative_resilience))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(system_type_summary, system_output_file)

cat("Regenerative resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nRegenerative resilience system-type summary exported to:", system_output_file, "\n")
print(system_type_summary)

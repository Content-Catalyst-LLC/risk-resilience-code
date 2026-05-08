library(readr)
library(dplyr)

input_file <- "../data/raw/early_warning_preparedness_panel.csv"
jurisdiction_output_file <- "../outputs/early_warning_jurisdiction_summary.csv"
hazard_output_file <- "../outputs/early_warning_hazard_summary.csv"

warning_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "jurisdiction",
  "hazard_type",
  "risk_knowledge_index",
  "forecast_skill_index",
  "lead_time_index",
  "communication_reach_index",
  "trust_strength_index",
  "preparedness_capacity_index",
  "response_capacity_index",
  "protocol_clarity_index",
  "equity_access_index",
  "household_preparedness_index",
  "community_preparedness_index",
  "institutional_preparedness_index",
  "uncertainty_burden_index",
  "access_barrier_index",
  "false_alarm_strain_index",
  "missed_alarm_risk_index",
  "institutional_fragmentation_index",
  "vulnerability_exposure_index"
)

missing_cols <- setdiff(required_cols, names(warning_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(warning_df)[grepl("_index$", names(warning_df))]

invalid_index_cols <- index_cols[
  vapply(
    warning_df[index_cols],
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

warning_df <- warning_df %>%
  mutate(
    warning_effectiveness_proxy = (
      risk_knowledge_index +
        forecast_skill_index +
        lead_time_index +
        communication_reach_index +
        trust_strength_index +
        preparedness_capacity_index +
        response_capacity_index +
        protocol_clarity_index +
        equity_access_index +
        (1 - uncertainty_burden_index) +
        (1 - access_barrier_index) +
        (1 - institutional_fragmentation_index)
    ) / 12,
    preparedness_system_proxy = (
      household_preparedness_index +
        community_preparedness_index +
        institutional_preparedness_index +
        preparedness_capacity_index +
        response_capacity_index +
        protocol_clarity_index +
        equity_access_index
    ) / 7,
    warning_vulnerability_proxy = (
      vulnerability_exposure_index +
        access_barrier_index +
        institutional_fragmentation_index +
        uncertainty_burden_index +
        missed_alarm_risk_index +
        false_alarm_strain_index +
        (1 - trust_strength_index) +
        (1 - communication_reach_index) +
        (1 - preparedness_capacity_index) +
        (1 - response_capacity_index)
    ) / 10,
    early_action_readiness_proxy = (
      warning_effectiveness_proxy +
        preparedness_system_proxy +
        (1 - warning_vulnerability_proxy) +
        equity_access_index
    ) / 4,
    preparedness_gap = preparedness_system_proxy - warning_vulnerability_proxy,
    readiness_band = case_when(
      early_action_readiness_proxy >= 0.75 ~ "Strong early warning and preparedness readiness",
      early_action_readiness_proxy >= 0.55 ~ "Moderate early warning and preparedness readiness",
      early_action_readiness_proxy >= 0.35 ~ "Limited early warning and preparedness readiness",
      TRUE ~ "Weak early warning and preparedness readiness"
    )
  )

jurisdiction_summary <- warning_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_early_action_readiness = mean(early_action_readiness_proxy, na.rm = TRUE),
    avg_warning_effectiveness = mean(warning_effectiveness_proxy, na.rm = TRUE),
    avg_preparedness_system = mean(preparedness_system_proxy, na.rm = TRUE),
    avg_warning_vulnerability = mean(warning_vulnerability_proxy, na.rm = TRUE),
    avg_risk_knowledge = mean(risk_knowledge_index, na.rm = TRUE),
    avg_forecast_skill = mean(forecast_skill_index, na.rm = TRUE),
    avg_lead_time = mean(lead_time_index, na.rm = TRUE),
    avg_communication_reach = mean(communication_reach_index, na.rm = TRUE),
    avg_trust_strength = mean(trust_strength_index, na.rm = TRUE),
    avg_preparedness_capacity = mean(preparedness_capacity_index, na.rm = TRUE),
    avg_response_capacity = mean(response_capacity_index, na.rm = TRUE),
    avg_equity_access = mean(equity_access_index, na.rm = TRUE),
    avg_access_barrier = mean(access_barrier_index, na.rm = TRUE),
    avg_vulnerability_exposure = mean(vulnerability_exposure_index, na.rm = TRUE),
    avg_preparedness_gap = mean(preparedness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    jurisdiction_readiness_band = case_when(
      avg_early_action_readiness >= 0.75 ~ "Strong early warning and preparedness readiness",
      avg_early_action_readiness >= 0.55 ~ "Moderate early warning and preparedness readiness",
      avg_early_action_readiness >= 0.35 ~ "Limited early warning and preparedness readiness",
      TRUE ~ "Weak early warning and preparedness readiness"
    )
  ) %>%
  arrange(desc(avg_early_action_readiness))

hazard_summary <- warning_df %>%
  group_by(hazard_type) %>%
  summarise(
    avg_early_action_readiness = mean(early_action_readiness_proxy, na.rm = TRUE),
    avg_warning_effectiveness = mean(warning_effectiveness_proxy, na.rm = TRUE),
    avg_preparedness_system = mean(preparedness_system_proxy, na.rm = TRUE),
    avg_warning_vulnerability = mean(warning_vulnerability_proxy, na.rm = TRUE),
    avg_risk_knowledge = mean(risk_knowledge_index, na.rm = TRUE),
    avg_forecast_skill = mean(forecast_skill_index, na.rm = TRUE),
    avg_lead_time = mean(lead_time_index, na.rm = TRUE),
    avg_communication_reach = mean(communication_reach_index, na.rm = TRUE),
    avg_trust_strength = mean(trust_strength_index, na.rm = TRUE),
    avg_preparedness_capacity = mean(preparedness_capacity_index, na.rm = TRUE),
    avg_response_capacity = mean(response_capacity_index, na.rm = TRUE),
    avg_equity_access = mean(equity_access_index, na.rm = TRUE),
    avg_access_barrier = mean(access_barrier_index, na.rm = TRUE),
    avg_vulnerability_exposure = mean(vulnerability_exposure_index, na.rm = TRUE),
    avg_preparedness_gap = mean(preparedness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_early_action_readiness))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(hazard_summary, hazard_output_file)

cat("Early warning jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nEarly warning hazard summary exported to:", hazard_output_file, "\n")
print(hazard_summary)

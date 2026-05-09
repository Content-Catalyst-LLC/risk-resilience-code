library(readr)
library(dplyr)

input_file <- "../data/raw/planetary_boundaries_risk_panel.csv"
status_output_file <- "../outputs/planetary_boundaries_status_summary.csv"
domain_output_file <- "../outputs/planetary_boundaries_domain_summary.csv"

pb_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "boundary_name",
  "earth_system_domain",
  "boundary_status",
  "boundary_transgression_index",
  "pressure_trend_index",
  "interaction_strength_index",
  "reversibility_risk_index",
  "human_system_exposure_index",
  "monitoring_confidence_index",
  "adaptive_capacity_index",
  "governance_quality_index",
  "justice_transition_index",
  "policy_response_index"
)

missing_cols <- setdiff(required_cols, names(pb_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(pb_df)[grepl("_index$", names(pb_df))]

invalid_index_cols <- index_cols[
  vapply(
    pb_df[index_cols],
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

pb_df <- pb_df %>%
  mutate(
    planetary_pressure_proxy = (
      boundary_transgression_index +
        pressure_trend_index +
        interaction_strength_index +
        reversibility_risk_index +
        human_system_exposure_index
    ) / 5,
    response_capacity_proxy = (
      monitoring_confidence_index +
        adaptive_capacity_index +
        governance_quality_index +
        justice_transition_index +
        policy_response_index
    ) / 5,
    planetary_system_risk_proxy = (
      planetary_pressure_proxy +
        human_system_exposure_index +
        reversibility_risk_index +
        (1 - response_capacity_proxy)
    ) / 4,
    earth_system_resilience_margin = response_capacity_proxy -
      planetary_pressure_proxy,
    risk_band = case_when(
      planetary_system_risk_proxy >= 0.75 ~ "Severe planetary system risk",
      planetary_system_risk_proxy >= 0.55 ~ "High planetary system risk",
      planetary_system_risk_proxy >= 0.35 ~ "Moderate planetary system risk",
      TRUE ~ "Lower planetary system risk"
    )
  )

status_summary <- pb_df %>%
  group_by(boundary_status) %>%
  summarise(
    avg_planetary_system_risk = mean(planetary_system_risk_proxy, na.rm = TRUE),
    avg_planetary_pressure = mean(planetary_pressure_proxy, na.rm = TRUE),
    avg_response_capacity = mean(response_capacity_proxy, na.rm = TRUE),
    avg_earth_system_resilience_margin = mean(earth_system_resilience_margin, na.rm = TRUE),
    avg_boundary_transgression = mean(boundary_transgression_index, na.rm = TRUE),
    avg_pressure_trend = mean(pressure_trend_index, na.rm = TRUE),
    avg_interaction_strength = mean(interaction_strength_index, na.rm = TRUE),
    avg_reversibility_risk = mean(reversibility_risk_index, na.rm = TRUE),
    avg_human_system_exposure = mean(human_system_exposure_index, na.rm = TRUE),
    avg_monitoring_confidence = mean(monitoring_confidence_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    avg_justice_transition = mean(justice_transition_index, na.rm = TRUE),
    boundaries = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_planetary_system_risk))

domain_summary <- pb_df %>%
  group_by(earth_system_domain) %>%
  summarise(
    avg_planetary_system_risk = mean(planetary_system_risk_proxy, na.rm = TRUE),
    avg_planetary_pressure = mean(planetary_pressure_proxy, na.rm = TRUE),
    avg_response_capacity = mean(response_capacity_proxy, na.rm = TRUE),
    avg_earth_system_resilience_margin = mean(earth_system_resilience_margin, na.rm = TRUE),
    avg_boundary_transgression = mean(boundary_transgression_index, na.rm = TRUE),
    avg_pressure_trend = mean(pressure_trend_index, na.rm = TRUE),
    avg_interaction_strength = mean(interaction_strength_index, na.rm = TRUE),
    avg_reversibility_risk = mean(reversibility_risk_index, na.rm = TRUE),
    avg_human_system_exposure = mean(human_system_exposure_index, na.rm = TRUE),
    avg_monitoring_confidence = mean(monitoring_confidence_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    avg_justice_transition = mean(justice_transition_index, na.rm = TRUE),
    boundaries = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_planetary_pressure))

write_csv(status_summary, status_output_file)
write_csv(domain_summary, domain_output_file)

cat("Planetary boundaries status summary exported to:", status_output_file, "\n")
print(status_summary)

cat("\nPlanetary boundaries domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

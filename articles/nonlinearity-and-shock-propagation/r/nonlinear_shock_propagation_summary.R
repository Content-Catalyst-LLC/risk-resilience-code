library(readr)
library(dplyr)

input_file <- "../data/raw/nonlinear_shock_propagation_panel.csv"
sector_output_file <- "../outputs/nonlinear_shock_sector_summary.csv"
shock_type_output_file <- "../outputs/nonlinear_shock_type_summary.csv"

shock_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "shock_type",
  "shock_intensity_index",
  "threshold_proximity_index",
  "network_centrality_index",
  "coupling_strength_index",
  "feedback_amplification_index",
  "hidden_stress_index",
  "exposure_inequality_index",
  "buffering_capacity_index",
  "modularity_index",
  "redundancy_index",
  "adaptive_response_index",
  "governance_quality_index"
)

missing_cols <- setdiff(required_cols, names(shock_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(shock_df)[grepl("_index$", names(shock_df))]

invalid_index_cols <- index_cols[
  vapply(
    shock_df[index_cols],
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

shock_df <- shock_df %>%
  mutate(
    propagation_pressure_proxy = (
      shock_intensity_index +
        threshold_proximity_index +
        network_centrality_index +
        coupling_strength_index +
        feedback_amplification_index +
        hidden_stress_index +
        exposure_inequality_index
    ) / 7,
    containment_capacity_proxy = (
      buffering_capacity_index +
        modularity_index +
        redundancy_index +
        adaptive_response_index +
        governance_quality_index
    ) / 5,
    nonlinear_propagation_risk_proxy = (
      propagation_pressure_proxy +
        (1 - containment_capacity_proxy)
    ) / 2,
    propagation_resilience_margin = containment_capacity_proxy -
      propagation_pressure_proxy,
    propagation_band = case_when(
      nonlinear_propagation_risk_proxy >= 0.75 ~ "Severe nonlinear propagation risk",
      nonlinear_propagation_risk_proxy >= 0.55 ~ "High nonlinear propagation risk",
      nonlinear_propagation_risk_proxy >= 0.35 ~ "Moderate nonlinear propagation risk",
      TRUE ~ "Lower nonlinear propagation risk"
    )
  )

sector_summary <- shock_df %>%
  group_by(sector) %>%
  summarise(
    avg_nonlinear_propagation_risk = mean(nonlinear_propagation_risk_proxy, na.rm = TRUE),
    avg_propagation_pressure = mean(propagation_pressure_proxy, na.rm = TRUE),
    avg_containment_capacity = mean(containment_capacity_proxy, na.rm = TRUE),
    avg_propagation_resilience_margin = mean(propagation_resilience_margin, na.rm = TRUE),
    avg_shock_intensity = mean(shock_intensity_index, na.rm = TRUE),
    avg_threshold_proximity = mean(threshold_proximity_index, na.rm = TRUE),
    avg_network_centrality = mean(network_centrality_index, na.rm = TRUE),
    avg_coupling_strength = mean(coupling_strength_index, na.rm = TRUE),
    avg_feedback_amplification = mean(feedback_amplification_index, na.rm = TRUE),
    avg_hidden_stress = mean(hidden_stress_index, na.rm = TRUE),
    avg_exposure_inequality = mean(exposure_inequality_index, na.rm = TRUE),
    avg_buffering_capacity = mean(buffering_capacity_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_adaptive_response = mean(adaptive_response_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_nonlinear_propagation_risk))

shock_type_summary <- shock_df %>%
  group_by(shock_type) %>%
  summarise(
    avg_nonlinear_propagation_risk = mean(nonlinear_propagation_risk_proxy, na.rm = TRUE),
    avg_propagation_pressure = mean(propagation_pressure_proxy, na.rm = TRUE),
    avg_containment_capacity = mean(containment_capacity_proxy, na.rm = TRUE),
    avg_propagation_resilience_margin = mean(propagation_resilience_margin, na.rm = TRUE),
    avg_shock_intensity = mean(shock_intensity_index, na.rm = TRUE),
    avg_threshold_proximity = mean(threshold_proximity_index, na.rm = TRUE),
    avg_network_centrality = mean(network_centrality_index, na.rm = TRUE),
    avg_coupling_strength = mean(coupling_strength_index, na.rm = TRUE),
    avg_feedback_amplification = mean(feedback_amplification_index, na.rm = TRUE),
    avg_hidden_stress = mean(hidden_stress_index, na.rm = TRUE),
    avg_exposure_inequality = mean(exposure_inequality_index, na.rm = TRUE),
    avg_buffering_capacity = mean(buffering_capacity_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_adaptive_response = mean(adaptive_response_index, na.rm = TRUE),
    avg_governance_quality = mean(governance_quality_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_propagation_pressure))

write_csv(sector_summary, sector_output_file)
write_csv(shock_type_summary, shock_type_output_file)

cat("Nonlinear shock sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nNonlinear shock-type summary exported to:", shock_type_output_file, "\n")
print(shock_type_summary)

library(readr)
library(dplyr)

input_file <- "../data/raw/path_dependence_lock_in_resilience_traps_panel.csv"
sector_output_file <- "../outputs/lock_in_sector_summary.csv"
pathway_output_file <- "../outputs/lock_in_pathway_type_summary.csv"

trap_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "pathway_type",
  "sunk_cost_index",
  "infrastructure_rigidity_index",
  "institutional_inertia_index",
  "incumbent_power_index",
  "social_dependence_index",
  "technological_incompatibility_index",
  "ecological_feedback_index",
  "alternative_capacity_index",
  "adaptive_governance_index",
  "public_legitimacy_index",
  "justice_transition_index",
  "reversibility_index"
)

missing_cols <- setdiff(required_cols, names(trap_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(trap_df)[grepl("_index$", names(trap_df))]

invalid_index_cols <- index_cols[
  vapply(
    trap_df[index_cols],
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

trap_df <- trap_df %>%
  mutate(
    lock_in_pressure_proxy = (
      sunk_cost_index +
        infrastructure_rigidity_index +
        institutional_inertia_index +
        incumbent_power_index +
        social_dependence_index +
        technological_incompatibility_index +
        ecological_feedback_index
    ) / 7,
    transformation_capacity_proxy = (
      alternative_capacity_index +
        adaptive_governance_index +
        public_legitimacy_index +
        justice_transition_index +
        reversibility_index
    ) / 5,
    resilience_trap_risk_proxy = (
      lock_in_pressure_proxy +
        (1 - transformation_capacity_proxy)
    ) / 2,
    transformation_readiness_proxy = (
      transformation_capacity_proxy +
        (1 - lock_in_pressure_proxy)
    ) / 2,
    escape_gap = transformation_capacity_proxy - lock_in_pressure_proxy,
    trap_band = case_when(
      resilience_trap_risk_proxy >= 0.75 ~ "Severe resilience trap risk",
      resilience_trap_risk_proxy >= 0.55 ~ "High resilience trap risk",
      resilience_trap_risk_proxy >= 0.35 ~ "Moderate resilience trap risk",
      TRUE ~ "Lower resilience trap risk"
    )
  )

sector_summary <- trap_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_trap_risk = mean(resilience_trap_risk_proxy, na.rm = TRUE),
    avg_lock_in_pressure = mean(lock_in_pressure_proxy, na.rm = TRUE),
    avg_transformation_capacity = mean(transformation_capacity_proxy, na.rm = TRUE),
    avg_transformation_readiness = mean(transformation_readiness_proxy, na.rm = TRUE),
    avg_escape_gap = mean(escape_gap, na.rm = TRUE),
    avg_sunk_cost = mean(sunk_cost_index, na.rm = TRUE),
    avg_infrastructure_rigidity = mean(infrastructure_rigidity_index, na.rm = TRUE),
    avg_institutional_inertia = mean(institutional_inertia_index, na.rm = TRUE),
    avg_incumbent_power = mean(incumbent_power_index, na.rm = TRUE),
    avg_social_dependence = mean(social_dependence_index, na.rm = TRUE),
    avg_technological_incompatibility = mean(technological_incompatibility_index, na.rm = TRUE),
    avg_ecological_feedback = mean(ecological_feedback_index, na.rm = TRUE),
    avg_alternative_capacity = mean(alternative_capacity_index, na.rm = TRUE),
    avg_adaptive_governance = mean(adaptive_governance_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_justice_transition = mean(justice_transition_index, na.rm = TRUE),
    avg_reversibility = mean(reversibility_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_trap_risk))

pathway_summary <- trap_df %>%
  group_by(pathway_type) %>%
  summarise(
    avg_resilience_trap_risk = mean(resilience_trap_risk_proxy, na.rm = TRUE),
    avg_lock_in_pressure = mean(lock_in_pressure_proxy, na.rm = TRUE),
    avg_transformation_capacity = mean(transformation_capacity_proxy, na.rm = TRUE),
    avg_transformation_readiness = mean(transformation_readiness_proxy, na.rm = TRUE),
    avg_escape_gap = mean(escape_gap, na.rm = TRUE),
    avg_sunk_cost = mean(sunk_cost_index, na.rm = TRUE),
    avg_infrastructure_rigidity = mean(infrastructure_rigidity_index, na.rm = TRUE),
    avg_institutional_inertia = mean(institutional_inertia_index, na.rm = TRUE),
    avg_incumbent_power = mean(incumbent_power_index, na.rm = TRUE),
    avg_social_dependence = mean(social_dependence_index, na.rm = TRUE),
    avg_technological_incompatibility = mean(technological_incompatibility_index, na.rm = TRUE),
    avg_ecological_feedback = mean(ecological_feedback_index, na.rm = TRUE),
    avg_alternative_capacity = mean(alternative_capacity_index, na.rm = TRUE),
    avg_adaptive_governance = mean(adaptive_governance_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_justice_transition = mean(justice_transition_index, na.rm = TRUE),
    avg_reversibility = mean(reversibility_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_lock_in_pressure))

write_csv(sector_summary, sector_output_file)
write_csv(pathway_summary, pathway_output_file)

cat("Lock-in sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nLock-in pathway-type summary exported to:", pathway_output_file, "\n")
print(pathway_summary)

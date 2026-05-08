library(readr)
library(dplyr)

input_file <- "../data/raw/risk_governance_institutions_panel.csv"
jurisdiction_output_file <- "../outputs/risk_governance_jurisdiction_summary.csv"
domain_output_file <- "../outputs/risk_governance_domain_summary.csv"

risk_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "institution_or_system",
  "jurisdiction",
  "risk_domain",
  "anticipatory_capacity_index",
  "appraisal_quality_index",
  "coordination_capacity_index",
  "participation_strength_index",
  "transparency_index",
  "legitimacy_index",
  "learning_capacity_index",
  "institutional_memory_index",
  "justice_orientation_index",
  "monitoring_feedback_index",
  "policy_revision_capacity_index",
  "fragmentation_index",
  "uncertainty_load_index",
  "capture_risk_index",
  "systemic_risk_exposure_index",
  "vulnerability_exposure_index"
)

missing_cols <- setdiff(required_cols, names(risk_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(risk_df)[grepl("_index$", names(risk_df))]

invalid_index_cols <- index_cols[
  vapply(
    risk_df[index_cols],
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

risk_df <- risk_df %>%
  mutate(
    risk_governance_quality_proxy = (
      anticipatory_capacity_index +
        appraisal_quality_index +
        coordination_capacity_index +
        participation_strength_index +
        transparency_index +
        legitimacy_index +
        learning_capacity_index +
        institutional_memory_index +
        justice_orientation_index +
        monitoring_feedback_index +
        policy_revision_capacity_index
    ) / 11,
    adaptive_institutional_capacity_proxy = (
      monitoring_feedback_index +
        policy_revision_capacity_index +
        coordination_capacity_index +
        learning_capacity_index +
        institutional_memory_index +
        participation_strength_index +
        legitimacy_index +
        justice_orientation_index
    ) / 8,
    governance_vulnerability_proxy = (
      fragmentation_index +
        uncertainty_load_index +
        capture_risk_index +
        systemic_risk_exposure_index +
        vulnerability_exposure_index +
        (1 - coordination_capacity_index) +
        (1 - transparency_index) +
        (1 - learning_capacity_index)
    ) / 8,
    resilience_governance_proxy = (
      risk_governance_quality_proxy +
        adaptive_institutional_capacity_proxy +
        (1 - governance_vulnerability_proxy) +
        justice_orientation_index
    ) / 4,
    capacity_gap = risk_governance_quality_proxy - governance_vulnerability_proxy,
    governance_band = case_when(
      resilience_governance_proxy >= 0.75 ~ "Strong adaptive risk governance",
      resilience_governance_proxy >= 0.55 ~ "Moderate adaptive risk governance",
      resilience_governance_proxy >= 0.35 ~ "Limited adaptive risk governance",
      TRUE ~ "Weak adaptive risk governance"
    )
  )

jurisdiction_summary <- risk_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_resilience_governance = mean(resilience_governance_proxy, na.rm = TRUE),
    avg_risk_governance_quality = mean(risk_governance_quality_proxy, na.rm = TRUE),
    avg_adaptive_institutional_capacity = mean(adaptive_institutional_capacity_proxy, na.rm = TRUE),
    avg_governance_vulnerability = mean(governance_vulnerability_proxy, na.rm = TRUE),
    avg_anticipatory_capacity = mean(anticipatory_capacity_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_participation_strength = mean(participation_strength_index, na.rm = TRUE),
    avg_transparency = mean(transparency_index, na.rm = TRUE),
    avg_legitimacy = mean(legitimacy_index, na.rm = TRUE),
    avg_learning_capacity = mean(learning_capacity_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_fragmentation = mean(fragmentation_index, na.rm = TRUE),
    avg_uncertainty_load = mean(uncertainty_load_index, na.rm = TRUE),
    avg_capture_risk = mean(capture_risk_index, na.rm = TRUE),
    avg_systemic_risk_exposure = mean(systemic_risk_exposure_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    jurisdiction_governance_band = case_when(
      avg_resilience_governance >= 0.75 ~ "Strong adaptive risk governance",
      avg_resilience_governance >= 0.55 ~ "Moderate adaptive risk governance",
      avg_resilience_governance >= 0.35 ~ "Limited adaptive risk governance",
      TRUE ~ "Weak adaptive risk governance"
    )
  ) %>%
  arrange(desc(avg_resilience_governance))

domain_summary <- risk_df %>%
  group_by(risk_domain) %>%
  summarise(
    avg_resilience_governance = mean(resilience_governance_proxy, na.rm = TRUE),
    avg_risk_governance_quality = mean(risk_governance_quality_proxy, na.rm = TRUE),
    avg_adaptive_institutional_capacity = mean(adaptive_institutional_capacity_proxy, na.rm = TRUE),
    avg_governance_vulnerability = mean(governance_vulnerability_proxy, na.rm = TRUE),
    avg_anticipatory_capacity = mean(anticipatory_capacity_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_participation_strength = mean(participation_strength_index, na.rm = TRUE),
    avg_transparency = mean(transparency_index, na.rm = TRUE),
    avg_legitimacy = mean(legitimacy_index, na.rm = TRUE),
    avg_learning_capacity = mean(learning_capacity_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_fragmentation = mean(fragmentation_index, na.rm = TRUE),
    avg_uncertainty_load = mean(uncertainty_load_index, na.rm = TRUE),
    avg_capture_risk = mean(capture_risk_index, na.rm = TRUE),
    avg_systemic_risk_exposure = mean(systemic_risk_exposure_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_governance))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Risk governance jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nRisk governance domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

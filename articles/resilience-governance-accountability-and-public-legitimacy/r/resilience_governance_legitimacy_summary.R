library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_governance_legitimacy_panel.csv"
jurisdiction_output_file <- "../outputs/resilience_governance_jurisdiction_summary.csv"
domain_output_file <- "../outputs/resilience_governance_domain_summary.csv"

gov_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "institution_or_system",
  "jurisdiction",
  "risk_domain",
  "adaptive_capacity_index",
  "accountability_capacity_index",
  "public_legitimacy_index",
  "transparency_index",
  "participation_strength_index",
  "coordination_capacity_index",
  "learning_capacity_index",
  "institutional_memory_index",
  "justice_orientation_index",
  "oversight_strength_index",
  "remedy_availability_index",
  "correction_capacity_index",
  "fragmentation_index",
  "capture_risk_index",
  "trust_erosion_index",
  "vulnerability_exposure_index",
  "systemic_risk_exposure_index"
)

missing_cols <- setdiff(required_cols, names(gov_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(gov_df)[grepl("_index$", names(gov_df))]

invalid_index_cols <- index_cols[
  vapply(
    gov_df[index_cols],
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

gov_df <- gov_df %>%
  mutate(
    resilience_governance_quality_proxy = (
      adaptive_capacity_index +
        accountability_capacity_index +
        public_legitimacy_index +
        transparency_index +
        participation_strength_index +
        coordination_capacity_index +
        learning_capacity_index +
        institutional_memory_index +
        justice_orientation_index +
        oversight_strength_index +
        correction_capacity_index
    ) / 11,
    accountability_legitimacy_proxy = (
      accountability_capacity_index +
        public_legitimacy_index +
        transparency_index +
        oversight_strength_index +
        remedy_availability_index +
        correction_capacity_index +
        participation_strength_index +
        justice_orientation_index
    ) / 8,
    governance_vulnerability_proxy = (
      fragmentation_index +
        capture_risk_index +
        trust_erosion_index +
        vulnerability_exposure_index +
        systemic_risk_exposure_index +
        (1 - accountability_capacity_index) +
        (1 - transparency_index) +
        (1 - learning_capacity_index)
    ) / 8,
    legitimate_resilience_governance_proxy = (
      resilience_governance_quality_proxy +
        accountability_legitimacy_proxy +
        (1 - governance_vulnerability_proxy) +
        justice_orientation_index
    ) / 4,
    legitimacy_gap = accountability_legitimacy_proxy - governance_vulnerability_proxy,
    governance_band = case_when(
      legitimate_resilience_governance_proxy >= 0.75 ~ "Strong legitimate resilience governance",
      legitimate_resilience_governance_proxy >= 0.55 ~ "Moderate legitimate resilience governance",
      legitimate_resilience_governance_proxy >= 0.35 ~ "Limited legitimate resilience governance",
      TRUE ~ "Weak legitimate resilience governance"
    )
  )

jurisdiction_summary <- gov_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_legitimate_resilience_governance = mean(legitimate_resilience_governance_proxy, na.rm = TRUE),
    avg_resilience_governance_quality = mean(resilience_governance_quality_proxy, na.rm = TRUE),
    avg_accountability_legitimacy = mean(accountability_legitimacy_proxy, na.rm = TRUE),
    avg_governance_vulnerability = mean(governance_vulnerability_proxy, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_accountability_capacity = mean(accountability_capacity_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_transparency = mean(transparency_index, na.rm = TRUE),
    avg_participation_strength = mean(participation_strength_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_learning_capacity = mean(learning_capacity_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_oversight_strength = mean(oversight_strength_index, na.rm = TRUE),
    avg_remedy_availability = mean(remedy_availability_index, na.rm = TRUE),
    avg_fragmentation = mean(fragmentation_index, na.rm = TRUE),
    avg_capture_risk = mean(capture_risk_index, na.rm = TRUE),
    avg_trust_erosion = mean(trust_erosion_index, na.rm = TRUE),
    avg_legitimacy_gap = mean(legitimacy_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  mutate(
    jurisdiction_governance_band = case_when(
      avg_legitimate_resilience_governance >= 0.75 ~ "Strong legitimate resilience governance",
      avg_legitimate_resilience_governance >= 0.55 ~ "Moderate legitimate resilience governance",
      avg_legitimate_resilience_governance >= 0.35 ~ "Limited legitimate resilience governance",
      TRUE ~ "Weak legitimate resilience governance"
    )
  ) %>%
  arrange(desc(avg_legitimate_resilience_governance))

domain_summary <- gov_df %>%
  group_by(risk_domain) %>%
  summarise(
    avg_legitimate_resilience_governance = mean(legitimate_resilience_governance_proxy, na.rm = TRUE),
    avg_resilience_governance_quality = mean(resilience_governance_quality_proxy, na.rm = TRUE),
    avg_accountability_legitimacy = mean(accountability_legitimacy_proxy, na.rm = TRUE),
    avg_governance_vulnerability = mean(governance_vulnerability_proxy, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_accountability_capacity = mean(accountability_capacity_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_transparency = mean(transparency_index, na.rm = TRUE),
    avg_participation_strength = mean(participation_strength_index, na.rm = TRUE),
    avg_coordination_capacity = mean(coordination_capacity_index, na.rm = TRUE),
    avg_learning_capacity = mean(learning_capacity_index, na.rm = TRUE),
    avg_justice_orientation = mean(justice_orientation_index, na.rm = TRUE),
    avg_oversight_strength = mean(oversight_strength_index, na.rm = TRUE),
    avg_remedy_availability = mean(remedy_availability_index, na.rm = TRUE),
    avg_fragmentation = mean(fragmentation_index, na.rm = TRUE),
    avg_capture_risk = mean(capture_risk_index, na.rm = TRUE),
    avg_trust_erosion = mean(trust_erosion_index, na.rm = TRUE),
    avg_legitimacy_gap = mean(legitimacy_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_legitimate_resilience_governance))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Resilience governance jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nResilience governance domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

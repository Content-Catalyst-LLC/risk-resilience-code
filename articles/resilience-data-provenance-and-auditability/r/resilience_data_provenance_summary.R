library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_data_provenance_panel.csv"
jurisdiction_output_file <- "../outputs/resilience_data_provenance_jurisdiction_summary.csv"
domain_output_file <- "../outputs/resilience_data_provenance_domain_summary.csv"

data_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "dataset_name",
  "jurisdiction",
  "data_domain",
  "provenance_completeness_index",
  "metadata_quality_index",
  "lineage_clarity_index",
  "audit_evidence_index",
  "reproducibility_index",
  "data_quality_index",
  "version_control_index",
  "chain_of_custody_index",
  "equity_coverage_index",
  "community_validation_index",
  "privacy_safeguard_index",
  "security_control_index",
  "responsible_owner_index",
  "missingness_gap_index",
  "opacity_risk_index",
  "undocumented_transformation_index",
  "stale_data_risk_index",
  "sensitive_data_exposure_risk_index",
  "audit_gap_index"
)

missing_cols <- setdiff(required_cols, names(data_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(data_df)[grepl("_index$", names(data_df))]

invalid_index_cols <- index_cols[
  vapply(
    data_df[index_cols],
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

data_df <- data_df %>%
  mutate(
    provenance_strength_proxy = (
      provenance_completeness_index +
        metadata_quality_index +
        lineage_clarity_index +
        version_control_index +
        responsible_owner_index +
        data_quality_index +
        chain_of_custody_index
    ) / 7,
    auditability_strength_proxy = (
      audit_evidence_index +
        reproducibility_index +
        version_control_index +
        chain_of_custody_index +
        responsible_owner_index +
        metadata_quality_index +
        lineage_clarity_index
    ) / 7,
    ethical_governance_proxy = (
      privacy_safeguard_index +
        security_control_index +
        equity_coverage_index +
        community_validation_index +
        responsible_owner_index +
        data_quality_index
    ) / 6,
    data_risk_pressure_proxy = (
      missingness_gap_index +
        opacity_risk_index +
        undocumented_transformation_index +
        stale_data_risk_index +
        sensitive_data_exposure_risk_index +
        audit_gap_index
    ) / 6,
    resilience_data_trust_proxy = (
      provenance_strength_proxy +
        auditability_strength_proxy +
        ethical_governance_proxy +
        data_quality_index +
        (1 - data_risk_pressure_proxy)
    ) / 5,
    audit_readiness_gap = resilience_data_trust_proxy - data_risk_pressure_proxy,
    data_trust_band = case_when(
      resilience_data_trust_proxy >= 0.75 ~ "Strong resilience data trust",
      resilience_data_trust_proxy >= 0.55 ~ "Moderate resilience data trust",
      resilience_data_trust_proxy >= 0.35 ~ "Limited resilience data trust",
      TRUE ~ "Weak resilience data trust"
    )
  )

jurisdiction_summary <- data_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_resilience_data_trust = mean(resilience_data_trust_proxy, na.rm = TRUE),
    avg_provenance_strength = mean(provenance_strength_proxy, na.rm = TRUE),
    avg_auditability_strength = mean(auditability_strength_proxy, na.rm = TRUE),
    avg_ethical_governance = mean(ethical_governance_proxy, na.rm = TRUE),
    avg_data_risk_pressure = mean(data_risk_pressure_proxy, na.rm = TRUE),
    avg_metadata_quality = mean(metadata_quality_index, na.rm = TRUE),
    avg_lineage_clarity = mean(lineage_clarity_index, na.rm = TRUE),
    avg_reproducibility = mean(reproducibility_index, na.rm = TRUE),
    avg_chain_of_custody = mean(chain_of_custody_index, na.rm = TRUE),
    avg_equity_coverage = mean(equity_coverage_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_missingness_gap = mean(missingness_gap_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_undocumented_transformation = mean(undocumented_transformation_index, na.rm = TRUE),
    avg_audit_gap = mean(audit_gap_index, na.rm = TRUE),
    avg_audit_readiness_gap = mean(audit_readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_data_trust))

domain_summary <- data_df %>%
  group_by(data_domain) %>%
  summarise(
    avg_resilience_data_trust = mean(resilience_data_trust_proxy, na.rm = TRUE),
    avg_provenance_strength = mean(provenance_strength_proxy, na.rm = TRUE),
    avg_auditability_strength = mean(auditability_strength_proxy, na.rm = TRUE),
    avg_ethical_governance = mean(ethical_governance_proxy, na.rm = TRUE),
    avg_data_risk_pressure = mean(data_risk_pressure_proxy, na.rm = TRUE),
    avg_metadata_quality = mean(metadata_quality_index, na.rm = TRUE),
    avg_lineage_clarity = mean(lineage_clarity_index, na.rm = TRUE),
    avg_reproducibility = mean(reproducibility_index, na.rm = TRUE),
    avg_chain_of_custody = mean(chain_of_custody_index, na.rm = TRUE),
    avg_equity_coverage = mean(equity_coverage_index, na.rm = TRUE),
    avg_community_validation = mean(community_validation_index, na.rm = TRUE),
    avg_missingness_gap = mean(missingness_gap_index, na.rm = TRUE),
    avg_opacity_risk = mean(opacity_risk_index, na.rm = TRUE),
    avg_undocumented_transformation = mean(undocumented_transformation_index, na.rm = TRUE),
    avg_audit_gap = mean(audit_gap_index, na.rm = TRUE),
    avg_audit_readiness_gap = mean(audit_readiness_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_data_trust))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Resilience data provenance jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nResilience data provenance domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

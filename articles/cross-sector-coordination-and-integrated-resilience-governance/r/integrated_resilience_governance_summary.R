library(readr)
library(dplyr)

input_file <- "../data/raw/integrated_resilience_governance_panel.csv"
jurisdiction_output_file <- "../outputs/integrated_resilience_governance_jurisdiction_summary.csv"
domain_output_file <- "../outputs/integrated_resilience_governance_domain_summary.csv"

coord_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "jurisdiction",
  "governance_system",
  "primary_risk_domain",
  "cross_sector_coordination_index",
  "dependency_visibility_index",
  "governance_integration_index",
  "data_interoperability_index",
  "public_accountability_index",
  "justice_equity_index",
  "local_capability_index",
  "adaptive_learning_index",
  "investment_alignment_index",
  "fragmentation_risk_index",
  "mandate_conflict_index",
  "governance_data_gap_index",
  "maladaptation_risk_index",
  "private_operator_opacity_index",
  "accountability_diffusion_index"
)

missing_cols <- setdiff(required_cols, names(coord_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(coord_df)[grepl("_index$", names(coord_df))]

invalid_index_cols <- index_cols[
  vapply(
    coord_df[index_cols],
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

coord_df <- coord_df %>%
  mutate(
    integrated_governance_capacity_proxy = (
      cross_sector_coordination_index +
        dependency_visibility_index +
        governance_integration_index +
        data_interoperability_index +
        public_accountability_index +
        justice_equity_index +
        local_capability_index +
        adaptive_learning_index +
        investment_alignment_index
    ) / 9,
    coordination_fragility_pressure_proxy = (
      fragmentation_risk_index +
        mandate_conflict_index +
        governance_data_gap_index +
        maladaptation_risk_index +
        private_operator_opacity_index +
        accountability_diffusion_index
    ) / 6,
    integrated_resilience_governance_gap = integrated_governance_capacity_proxy -
      coordination_fragility_pressure_proxy,
    governance_readiness_band = case_when(
      integrated_governance_capacity_proxy >= 0.75 ~ "Strong integrated resilience governance capacity",
      integrated_governance_capacity_proxy >= 0.55 ~ "Moderate integrated resilience governance capacity",
      integrated_governance_capacity_proxy >= 0.35 ~ "Limited integrated resilience governance capacity",
      TRUE ~ "Weak integrated resilience governance capacity"
    )
  )

jurisdiction_summary <- coord_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_integrated_governance_capacity = mean(integrated_governance_capacity_proxy, na.rm = TRUE),
    avg_coordination_fragility_pressure = mean(coordination_fragility_pressure_proxy, na.rm = TRUE),
    avg_integrated_resilience_governance_gap = mean(integrated_resilience_governance_gap, na.rm = TRUE),
    avg_cross_sector_coordination = mean(cross_sector_coordination_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_governance_integration = mean(governance_integration_index, na.rm = TRUE),
    avg_data_interoperability = mean(data_interoperability_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    avg_justice_equity = mean(justice_equity_index, na.rm = TRUE),
    avg_local_capability = mean(local_capability_index, na.rm = TRUE),
    avg_adaptive_learning = mean(adaptive_learning_index, na.rm = TRUE),
    avg_investment_alignment = mean(investment_alignment_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_mandate_conflict = mean(mandate_conflict_index, na.rm = TRUE),
    avg_governance_data_gap = mean(governance_data_gap_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_private_operator_opacity = mean(private_operator_opacity_index, na.rm = TRUE),
    avg_accountability_diffusion = mean(accountability_diffusion_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_integrated_resilience_governance_gap))

domain_summary <- coord_df %>%
  group_by(primary_risk_domain) %>%
  summarise(
    avg_integrated_governance_capacity = mean(integrated_governance_capacity_proxy, na.rm = TRUE),
    avg_coordination_fragility_pressure = mean(coordination_fragility_pressure_proxy, na.rm = TRUE),
    avg_integrated_resilience_governance_gap = mean(integrated_resilience_governance_gap, na.rm = TRUE),
    avg_cross_sector_coordination = mean(cross_sector_coordination_index, na.rm = TRUE),
    avg_dependency_visibility = mean(dependency_visibility_index, na.rm = TRUE),
    avg_governance_integration = mean(governance_integration_index, na.rm = TRUE),
    avg_data_interoperability = mean(data_interoperability_index, na.rm = TRUE),
    avg_public_accountability = mean(public_accountability_index, na.rm = TRUE),
    avg_justice_equity = mean(justice_equity_index, na.rm = TRUE),
    avg_local_capability = mean(local_capability_index, na.rm = TRUE),
    avg_adaptive_learning = mean(adaptive_learning_index, na.rm = TRUE),
    avg_investment_alignment = mean(investment_alignment_index, na.rm = TRUE),
    avg_fragmentation_risk = mean(fragmentation_risk_index, na.rm = TRUE),
    avg_mandate_conflict = mean(mandate_conflict_index, na.rm = TRUE),
    avg_governance_data_gap = mean(governance_data_gap_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_private_operator_opacity = mean(private_operator_opacity_index, na.rm = TRUE),
    avg_accountability_diffusion = mean(accountability_diffusion_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_coordination_fragility_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Integrated resilience governance jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nIntegrated resilience governance domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

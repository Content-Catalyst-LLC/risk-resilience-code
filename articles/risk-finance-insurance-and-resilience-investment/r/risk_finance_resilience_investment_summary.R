library(readr)
library(dplyr)

input_file <- "../data/raw/risk_finance_resilience_investment_panel.csv"
sector_output_file <- "../outputs/risk_finance_sector_summary.csv"
domain_output_file <- "../outputs/risk_finance_domain_summary.csv"

finance_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "jurisdiction_or_portfolio",
  "risk_domain",
  "sector",
  "risk_visibility_index",
  "insurance_coverage_index",
  "prearranged_finance_index",
  "fiscal_capacity_index",
  "resilience_investment_index",
  "mitigation_incentive_index",
  "equity_protection_index",
  "insurance_affordability_index",
  "public_risk_pool_capacity_index",
  "contingent_credit_capacity_index",
  "catastrophe_bond_capacity_index",
  "social_protection_capacity_index",
  "disclosure_quality_index",
  "protection_gap_index",
  "debt_stress_index",
  "hidden_exposure_index",
  "systemic_transmission_risk_index",
  "maladaptation_risk_index"
)

missing_cols <- setdiff(required_cols, names(finance_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(finance_df)[grepl("_index$", names(finance_df))]

invalid_index_cols <- index_cols[
  vapply(
    finance_df[index_cols],
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

finance_df <- finance_df %>%
  mutate(
    resilience_finance_capacity_proxy = (
      risk_visibility_index +
        insurance_coverage_index +
        prearranged_finance_index +
        fiscal_capacity_index +
        resilience_investment_index +
        mitigation_incentive_index +
        equity_protection_index +
        insurance_affordability_index +
        public_risk_pool_capacity_index +
        contingent_credit_capacity_index +
        catastrophe_bond_capacity_index +
        social_protection_capacity_index
    ) / 12,
    protection_gap_pressure_proxy = (
      protection_gap_index +
        debt_stress_index +
        hidden_exposure_index +
        systemic_transmission_risk_index +
        maladaptation_risk_index +
        (1 - insurance_affordability_index) +
        (1 - insurance_coverage_index) +
        (1 - prearranged_finance_index) +
        (1 - equity_protection_index)
    ) / 9,
    risk_visibility_governance_proxy = (
      risk_visibility_index +
        disclosure_quality_index +
        mitigation_incentive_index +
        resilience_investment_index +
        equity_protection_index +
        (1 - hidden_exposure_index)
    ) / 6,
    resilience_adjusted_financial_risk_proxy = (
      protection_gap_pressure_proxy +
        (1 - resilience_finance_capacity_proxy) +
        (1 - risk_visibility_governance_proxy) +
        systemic_transmission_risk_index +
        debt_stress_index
    ) / 5,
    finance_resilience_gap = resilience_finance_capacity_proxy - protection_gap_pressure_proxy,
    risk_band = case_when(
      resilience_adjusted_financial_risk_proxy >= 0.75 ~ "Extreme resilience finance risk",
      resilience_adjusted_financial_risk_proxy >= 0.55 ~ "High resilience finance risk",
      resilience_adjusted_financial_risk_proxy >= 0.35 ~ "Moderate resilience finance risk",
      TRUE ~ "Lower resilience finance risk"
    )
  )

sector_summary <- finance_df %>%
  group_by(sector) %>%
  summarise(
    avg_resilience_adjusted_financial_risk = mean(resilience_adjusted_financial_risk_proxy, na.rm = TRUE),
    avg_resilience_finance_capacity = mean(resilience_finance_capacity_proxy, na.rm = TRUE),
    avg_protection_gap_pressure = mean(protection_gap_pressure_proxy, na.rm = TRUE),
    avg_risk_visibility_governance = mean(risk_visibility_governance_proxy, na.rm = TRUE),
    avg_insurance_coverage = mean(insurance_coverage_index, na.rm = TRUE),
    avg_insurance_affordability = mean(insurance_affordability_index, na.rm = TRUE),
    avg_prearranged_finance = mean(prearranged_finance_index, na.rm = TRUE),
    avg_resilience_investment = mean(resilience_investment_index, na.rm = TRUE),
    avg_fiscal_capacity = mean(fiscal_capacity_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_protection_gap = mean(protection_gap_index, na.rm = TRUE),
    avg_debt_stress = mean(debt_stress_index, na.rm = TRUE),
    avg_hidden_exposure = mean(hidden_exposure_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_finance_resilience_gap = mean(finance_resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_financial_risk))

domain_summary <- finance_df %>%
  group_by(risk_domain) %>%
  summarise(
    avg_resilience_adjusted_financial_risk = mean(resilience_adjusted_financial_risk_proxy, na.rm = TRUE),
    avg_resilience_finance_capacity = mean(resilience_finance_capacity_proxy, na.rm = TRUE),
    avg_protection_gap_pressure = mean(protection_gap_pressure_proxy, na.rm = TRUE),
    avg_risk_visibility_governance = mean(risk_visibility_governance_proxy, na.rm = TRUE),
    avg_insurance_coverage = mean(insurance_coverage_index, na.rm = TRUE),
    avg_insurance_affordability = mean(insurance_affordability_index, na.rm = TRUE),
    avg_prearranged_finance = mean(prearranged_finance_index, na.rm = TRUE),
    avg_resilience_investment = mean(resilience_investment_index, na.rm = TRUE),
    avg_fiscal_capacity = mean(fiscal_capacity_index, na.rm = TRUE),
    avg_equity_protection = mean(equity_protection_index, na.rm = TRUE),
    avg_protection_gap = mean(protection_gap_index, na.rm = TRUE),
    avg_debt_stress = mean(debt_stress_index, na.rm = TRUE),
    avg_hidden_exposure = mean(hidden_exposure_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_finance_resilience_gap = mean(finance_resilience_gap, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_adjusted_financial_risk))

write_csv(sector_summary, sector_output_file)
write_csv(domain_summary, domain_output_file)

cat("Risk finance sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nRisk finance domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

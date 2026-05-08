-- Risk Finance, Insurance, and Resilience Investment Panel Schema
-- Article: Risk Finance, Insurance, and Resilience Investment

CREATE TABLE IF NOT EXISTS risk_finance_resilience_investment_panel (
    finance_id INTEGER PRIMARY KEY,
    jurisdiction_or_portfolio TEXT NOT NULL,
    risk_domain TEXT NOT NULL,
    sector TEXT NOT NULL,

    risk_visibility_index REAL NOT NULL CHECK (risk_visibility_index BETWEEN 0 AND 1),
    insurance_coverage_index REAL NOT NULL CHECK (insurance_coverage_index BETWEEN 0 AND 1),
    prearranged_finance_index REAL NOT NULL CHECK (prearranged_finance_index BETWEEN 0 AND 1),
    fiscal_capacity_index REAL NOT NULL CHECK (fiscal_capacity_index BETWEEN 0 AND 1),
    resilience_investment_index REAL NOT NULL CHECK (resilience_investment_index BETWEEN 0 AND 1),
    mitigation_incentive_index REAL NOT NULL CHECK (mitigation_incentive_index BETWEEN 0 AND 1),
    equity_protection_index REAL NOT NULL CHECK (equity_protection_index BETWEEN 0 AND 1),
    insurance_affordability_index REAL NOT NULL CHECK (insurance_affordability_index BETWEEN 0 AND 1),
    public_risk_pool_capacity_index REAL NOT NULL CHECK (public_risk_pool_capacity_index BETWEEN 0 AND 1),
    contingent_credit_capacity_index REAL NOT NULL CHECK (contingent_credit_capacity_index BETWEEN 0 AND 1),
    catastrophe_bond_capacity_index REAL NOT NULL CHECK (catastrophe_bond_capacity_index BETWEEN 0 AND 1),
    social_protection_capacity_index REAL NOT NULL CHECK (social_protection_capacity_index BETWEEN 0 AND 1),
    disclosure_quality_index REAL NOT NULL CHECK (disclosure_quality_index BETWEEN 0 AND 1),
    protection_gap_index REAL NOT NULL CHECK (protection_gap_index BETWEEN 0 AND 1),
    debt_stress_index REAL NOT NULL CHECK (debt_stress_index BETWEEN 0 AND 1),
    hidden_exposure_index REAL NOT NULL CHECK (hidden_exposure_index BETWEEN 0 AND 1),
    systemic_transmission_risk_index REAL NOT NULL CHECK (systemic_transmission_risk_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS risk_finance_resilience_investment_view AS
SELECT
    finance_id,
    jurisdiction_or_portfolio,
    risk_domain,
    sector,

    (
        0.11 * risk_visibility_index +
        0.10 * insurance_coverage_index +
        0.10 * prearranged_finance_index +
        0.10 * fiscal_capacity_index +
        0.11 * resilience_investment_index +
        0.09 * mitigation_incentive_index +
        0.09 * equity_protection_index +
        0.08 * insurance_affordability_index +
        0.07 * public_risk_pool_capacity_index +
        0.06 * contingent_credit_capacity_index +
        0.05 * catastrophe_bond_capacity_index +
        0.04 * social_protection_capacity_index
    ) AS resilience_finance_capacity_score,

    (
        0.18 * protection_gap_index +
        0.15 * debt_stress_index +
        0.14 * hidden_exposure_index +
        0.13 * systemic_transmission_risk_index +
        0.12 * maladaptation_risk_index +
        0.10 * (1 - insurance_affordability_index) +
        0.08 * (1 - insurance_coverage_index) +
        0.06 * (1 - prearranged_finance_index) +
        0.04 * (1 - equity_protection_index)
    ) AS protection_gap_pressure_score,

    (
        0.24 * risk_visibility_index +
        0.22 * disclosure_quality_index +
        0.18 * mitigation_incentive_index +
        0.16 * resilience_investment_index +
        0.12 * equity_protection_index +
        0.08 * (1 - hidden_exposure_index)
    ) AS risk_visibility_and_governance_score

FROM risk_finance_resilience_investment_panel;

-- Regenerative Resilience Panel Schema
-- Article: From Risk Management to Regenerative Capacity

CREATE TABLE IF NOT EXISTS regenerative_resilience_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    risk_management_capacity_index REAL NOT NULL CHECK (risk_management_capacity_index BETWEEN 0 AND 1),
    ecological_restoration_index REAL NOT NULL CHECK (ecological_restoration_index BETWEEN 0 AND 1),
    social_capacity_index REAL NOT NULL CHECK (social_capacity_index BETWEEN 0 AND 1),
    institutional_learning_index REAL NOT NULL CHECK (institutional_learning_index BETWEEN 0 AND 1),
    justice_orientation_index REAL NOT NULL CHECK (justice_orientation_index BETWEEN 0 AND 1),
    long_term_investment_index REAL NOT NULL CHECK (long_term_investment_index BETWEEN 0 AND 1),
    livelihood_viability_index REAL NOT NULL CHECK (livelihood_viability_index BETWEEN 0 AND 1),
    ecological_function_index REAL NOT NULL CHECK (ecological_function_index BETWEEN 0 AND 1),
    public_trust_index REAL NOT NULL CHECK (public_trust_index BETWEEN 0 AND 1),
    adaptive_governance_index REAL NOT NULL CHECK (adaptive_governance_index BETWEEN 0 AND 1),
    community_participation_index REAL NOT NULL CHECK (community_participation_index BETWEEN 0 AND 1),
    regenerative_finance_index REAL NOT NULL CHECK (regenerative_finance_index BETWEEN 0 AND 1),
    depletion_pressure_index REAL NOT NULL CHECK (depletion_pressure_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),
    extractive_pressure_index REAL NOT NULL CHECK (extractive_pressure_index BETWEEN 0 AND 1),
    institutional_fatigue_index REAL NOT NULL CHECK (institutional_fatigue_index BETWEEN 0 AND 1),
    chronic_vulnerability_index REAL NOT NULL CHECK (chronic_vulnerability_index BETWEEN 0 AND 1),
    recovery_only_bias_index REAL NOT NULL CHECK (recovery_only_bias_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS regenerative_resilience_view AS
SELECT
    system_id,
    system_name,
    jurisdiction,
    system_type,

    (
        0.28 * risk_management_capacity_index +
        0.18 * adaptive_governance_index +
        0.16 * institutional_learning_index +
        0.14 * public_trust_index +
        0.12 * community_participation_index +
        0.12 * long_term_investment_index
    ) AS defensive_risk_management_score,

    (
        0.16 * ecological_restoration_index +
        0.14 * ecological_function_index +
        0.14 * social_capacity_index +
        0.13 * institutional_learning_index +
        0.12 * justice_orientation_index +
        0.11 * livelihood_viability_index +
        0.10 * long_term_investment_index +
        0.10 * regenerative_finance_index
    ) AS regenerative_capacity_score,

    (
        0.18 * depletion_pressure_index +
        0.17 * maladaptation_risk_index +
        0.16 * extractive_pressure_index +
        0.15 * institutional_fatigue_index +
        0.14 * chronic_vulnerability_index +
        0.10 * recovery_only_bias_index +
        0.05 * (1 - ecological_function_index) +
        0.05 * (1 - justice_orientation_index)
    ) AS depletion_and_maladaptation_pressure_score

FROM regenerative_resilience_panel;

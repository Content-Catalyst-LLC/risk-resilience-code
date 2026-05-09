-- Resilience Indicators and Measurement Panel Schema
-- Article: Resilience Indicators and Measurement

CREATE TABLE IF NOT EXISTS resilience_indicators_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    capacity_index REAL NOT NULL CHECK (capacity_index BETWEEN 0 AND 1),
    asset_index REAL NOT NULL CHECK (asset_index BETWEEN 0 AND 1),
    process_index REAL NOT NULL CHECK (process_index BETWEEN 0 AND 1),
    outcome_index REAL NOT NULL CHECK (outcome_index BETWEEN 0 AND 1),
    equity_protection_index REAL NOT NULL CHECK (equity_protection_index BETWEEN 0 AND 1),
    service_continuity_index REAL NOT NULL CHECK (service_continuity_index BETWEEN 0 AND 1),
    recovery_performance_index REAL NOT NULL CHECK (recovery_performance_index BETWEEN 0 AND 1),
    adaptive_learning_index REAL NOT NULL CHECK (adaptive_learning_index BETWEEN 0 AND 1),
    institutional_capacity_index REAL NOT NULL CHECK (institutional_capacity_index BETWEEN 0 AND 1),
    ecological_condition_index REAL NOT NULL CHECK (ecological_condition_index BETWEEN 0 AND 1),
    social_protection_index REAL NOT NULL CHECK (social_protection_index BETWEEN 0 AND 1),
    financial_protection_index REAL NOT NULL CHECK (financial_protection_index BETWEEN 0 AND 1),
    vulnerability_index REAL NOT NULL CHECK (vulnerability_index BETWEEN 0 AND 1),
    exposure_index REAL NOT NULL CHECK (exposure_index BETWEEN 0 AND 1),
    distributional_inequality_index REAL NOT NULL CHECK (distributional_inequality_index BETWEEN 0 AND 1),
    measurement_uncertainty_index REAL NOT NULL CHECK (measurement_uncertainty_index BETWEEN 0 AND 1),
    data_quality_gap_index REAL NOT NULL CHECK (data_quality_gap_index BETWEEN 0 AND 1),
    false_precision_risk_index REAL NOT NULL CHECK (false_precision_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS resilience_indicators_view AS
SELECT
    system_id,
    system_name,
    jurisdiction,
    system_type,

    (
        0.34 * capacity_index +
        0.33 * asset_index +
        0.33 * process_index
    ) AS capacity_asset_process_score,

    (
        0.22 * outcome_index +
        0.20 * service_continuity_index +
        0.18 * recovery_performance_index +
        0.16 * adaptive_learning_index +
        0.12 * institutional_capacity_index +
        0.06 * ecological_condition_index +
        0.06 * social_protection_index
    ) AS performance_outcome_score,

    (
        0.22 * vulnerability_index +
        0.20 * exposure_index +
        0.18 * distributional_inequality_index +
        0.15 * measurement_uncertainty_index +
        0.13 * data_quality_gap_index +
        0.12 * false_precision_risk_index
    ) AS measurement_vulnerability_score

FROM resilience_indicators_panel;

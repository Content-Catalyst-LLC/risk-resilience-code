-- AI Resilience System Panel Schema
-- Article: Resilience in the Age of AI and Automated Systems

CREATE TABLE IF NOT EXISTS ai_resilience_system_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    ai_use_case TEXT NOT NULL,

    model_reliability_index REAL NOT NULL CHECK (model_reliability_index BETWEEN 0 AND 1),
    monitoring_capacity_index REAL NOT NULL CHECK (monitoring_capacity_index BETWEEN 0 AND 1),
    oversight_capacity_index REAL NOT NULL CHECK (oversight_capacity_index BETWEEN 0 AND 1),
    governance_strength_index REAL NOT NULL CHECK (governance_strength_index BETWEEN 0 AND 1),
    explainability_index REAL NOT NULL CHECK (explainability_index BETWEEN 0 AND 1),
    contestability_index REAL NOT NULL CHECK (contestability_index BETWEEN 0 AND 1),
    fallback_capacity_index REAL NOT NULL CHECK (fallback_capacity_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    bias_management_index REAL NOT NULL CHECK (bias_management_index BETWEEN 0 AND 1),
    privacy_protection_index REAL NOT NULL CHECK (privacy_protection_index BETWEEN 0 AND 1),
    cyber_resilience_index REAL NOT NULL CHECK (cyber_resilience_index BETWEEN 0 AND 1),
    concentration_risk_index REAL NOT NULL CHECK (concentration_risk_index BETWEEN 0 AND 1),
    automation_dependence_index REAL NOT NULL CHECK (automation_dependence_index BETWEEN 0 AND 1),
    drift_risk_index REAL NOT NULL CHECK (drift_risk_index BETWEEN 0 AND 1),
    opacity_risk_index REAL NOT NULL CHECK (opacity_risk_index BETWEEN 0 AND 1),
    public_accountability_index REAL NOT NULL CHECK (public_accountability_index BETWEEN 0 AND 1),
    service_criticality_index REAL NOT NULL CHECK (service_criticality_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS ai_resilience_risk_view AS
SELECT
    system_id,
    system_name,
    sector,
    ai_use_case,

    (
        0.12 * model_reliability_index +
        0.11 * monitoring_capacity_index +
        0.11 * oversight_capacity_index +
        0.11 * governance_strength_index +
        0.09 * explainability_index +
        0.09 * contestability_index +
        0.09 * fallback_capacity_index +
        0.08 * data_quality_index +
        0.07 * bias_management_index +
        0.06 * privacy_protection_index +
        0.07 * cyber_resilience_index
    ) AS ai_resilience_capacity_score,

    (
        0.16 * concentration_risk_index +
        0.15 * automation_dependence_index +
        0.15 * drift_risk_index +
        0.14 * opacity_risk_index +
        0.10 * (1 - fallback_capacity_index) +
        0.10 * (1 - monitoring_capacity_index) +
        0.08 * (1 - oversight_capacity_index) +
        0.07 * (1 - contestability_index) +
        0.05 * (1 - public_accountability_index)
    ) AS automation_fragility_score

FROM ai_resilience_system_panel;

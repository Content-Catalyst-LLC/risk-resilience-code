-- AI, Automation, and Resilience Under Algorithmic Governance Schema
-- Article: AI, Automation, and Resilience Under Algorithmic Governance

CREATE TABLE IF NOT EXISTS ai_algorithmic_resilience_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_domain TEXT NOT NULL,

    model_capability_index REAL NOT NULL CHECK (model_capability_index BETWEEN 0 AND 1),
    institutional_governance_index REAL NOT NULL CHECK (institutional_governance_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    human_oversight_index REAL NOT NULL CHECK (human_oversight_index BETWEEN 0 AND 1),
    auditability_index REAL NOT NULL CHECK (auditability_index BETWEEN 0 AND 1),
    system_robustness_index REAL NOT NULL CHECK (system_robustness_index BETWEEN 0 AND 1),
    equity_testing_index REAL NOT NULL CHECK (equity_testing_index BETWEEN 0 AND 1),
    security_control_index REAL NOT NULL CHECK (security_control_index BETWEEN 0 AND 1),
    fallback_capacity_index REAL NOT NULL CHECK (fallback_capacity_index BETWEEN 0 AND 1),
    public_contestability_index REAL NOT NULL CHECK (public_contestability_index BETWEEN 0 AND 1),
    monitoring_maturity_index REAL NOT NULL CHECK (monitoring_maturity_index BETWEEN 0 AND 1),
    incident_response_index REAL NOT NULL CHECK (incident_response_index BETWEEN 0 AND 1),
    vendor_accountability_index REAL NOT NULL CHECK (vendor_accountability_index BETWEEN 0 AND 1),

    opacity_risk_index REAL NOT NULL CHECK (opacity_risk_index BETWEEN 0 AND 1),
    bias_severity_index REAL NOT NULL CHECK (bias_severity_index BETWEEN 0 AND 1),
    model_drift_risk_index REAL NOT NULL CHECK (model_drift_risk_index BETWEEN 0 AND 1),
    automation_dependency_index REAL NOT NULL CHECK (automation_dependency_index BETWEEN 0 AND 1),
    vendor_concentration_risk_index REAL NOT NULL CHECK (vendor_concentration_risk_index BETWEEN 0 AND 1),
    cyber_exposure_index REAL NOT NULL CHECK (cyber_exposure_index BETWEEN 0 AND 1),
    legitimacy_risk_index REAL NOT NULL CHECK (legitimacy_risk_index BETWEEN 0 AND 1),

    deployment_stage TEXT,
    model_owner TEXT,
    data_owner TEXT,
    observation_year INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS ai_algorithmic_incidents (
    incident_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    incident_date TEXT NOT NULL,
    incident_type TEXT NOT NULL,
    affected_group TEXT,
    severity_index REAL CHECK (severity_index BETWEEN 0 AND 1),
    root_cause TEXT,
    corrective_action TEXT,
    public_notice_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS ai_algorithmic_resilience_view AS
SELECT
    system_id,
    system_name,
    jurisdiction,
    system_domain,

    (
        0.18 * model_capability_index +
        0.16 * data_quality_index +
        0.15 * system_robustness_index +
        0.14 * monitoring_maturity_index +
        0.13 * incident_response_index +
        0.12 * security_control_index +
        0.12 * fallback_capacity_index
    ) AS ai_resilience_capability_score,

    (
        0.18 * institutional_governance_index +
        0.16 * human_oversight_index +
        0.15 * auditability_index +
        0.14 * equity_testing_index +
        0.13 * public_contestability_index +
        0.12 * vendor_accountability_index +
        0.12 * monitoring_maturity_index
    ) AS algorithmic_governance_score,

    (
        0.17 * opacity_risk_index +
        0.16 * bias_severity_index +
        0.15 * model_drift_risk_index +
        0.15 * automation_dependency_index +
        0.14 * vendor_concentration_risk_index +
        0.13 * cyber_exposure_index +
        0.10 * legitimacy_risk_index
    ) AS algorithmic_fragility_pressure_score

FROM ai_algorithmic_resilience_panel;

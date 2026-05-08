-- Digital Twin Infrastructure Panel Schema
-- Article: Digital Twins, Sensing, and Infrastructure Resilience

CREATE TABLE IF NOT EXISTS digital_twin_infrastructure_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    infrastructure_type TEXT NOT NULL,

    sensing_coverage_index REAL NOT NULL CHECK (sensing_coverage_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    data_timeliness_index REAL NOT NULL CHECK (data_timeliness_index BETWEEN 0 AND 1),
    model_validation_index REAL NOT NULL CHECK (model_validation_index BETWEEN 0 AND 1),
    decision_integration_index REAL NOT NULL CHECK (decision_integration_index BETWEEN 0 AND 1),
    dependency_visibility_index REAL NOT NULL CHECK (dependency_visibility_index BETWEEN 0 AND 1),
    predictive_maintenance_usefulness_index REAL NOT NULL CHECK (predictive_maintenance_usefulness_index BETWEEN 0 AND 1),
    climate_adaptation_usefulness_index REAL NOT NULL CHECK (climate_adaptation_usefulness_index BETWEEN 0 AND 1),
    service_continuity_relevance_index REAL NOT NULL CHECK (service_continuity_relevance_index BETWEEN 0 AND 1),
    cyber_risk_index REAL NOT NULL CHECK (cyber_risk_index BETWEEN 0 AND 1),
    platform_dependency_index REAL NOT NULL CHECK (platform_dependency_index BETWEEN 0 AND 1),
    model_uncertainty_index REAL NOT NULL CHECK (model_uncertainty_index BETWEEN 0 AND 1),
    equity_coverage_index REAL NOT NULL CHECK (equity_coverage_index BETWEEN 0 AND 1),
    governance_capacity_index REAL NOT NULL CHECK (governance_capacity_index BETWEEN 0 AND 1),
    public_accountability_index REAL NOT NULL CHECK (public_accountability_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS digital_twin_resilience_view AS
SELECT
    system_id,
    system_name,
    sector,
    infrastructure_type,

    (
        0.13 * sensing_coverage_index +
        0.12 * data_quality_index +
        0.09 * data_timeliness_index +
        0.13 * model_validation_index +
        0.13 * decision_integration_index +
        0.10 * dependency_visibility_index +
        0.10 * predictive_maintenance_usefulness_index +
        0.08 * climate_adaptation_usefulness_index +
        0.06 * equity_coverage_index +
        0.06 * governance_capacity_index
    ) AS digital_twin_resilience_contribution,

    (
        0.18 * cyber_risk_index +
        0.15 * platform_dependency_index +
        0.15 * model_uncertainty_index +
        0.12 * (1 - model_validation_index) +
        0.12 * (1 - data_quality_index) +
        0.10 * (1 - governance_capacity_index) +
        0.09 * (1 - public_accountability_index) +
        0.09 * (1 - equity_coverage_index)
    ) AS digital_twin_implementation_risk

FROM digital_twin_infrastructure_panel;

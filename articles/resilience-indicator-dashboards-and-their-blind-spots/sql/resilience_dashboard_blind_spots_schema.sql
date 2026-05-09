-- Resilience Indicator Dashboards and Their Blind Spots Panel Schema
-- Article: Resilience Indicator Dashboards and Their Blind Spots

CREATE TABLE IF NOT EXISTS resilience_dashboard_blind_spots_panel (
    dashboard_id INTEGER PRIMARY KEY,
    dashboard_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    dashboard_type TEXT NOT NULL,

    indicator_coverage_index REAL NOT NULL CHECK (indicator_coverage_index BETWEEN 0 AND 1),
    dashboard_usability_index REAL NOT NULL CHECK (dashboard_usability_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    update_frequency_index REAL NOT NULL CHECK (update_frequency_index BETWEEN 0 AND 1),
    disaggregation_strength_index REAL NOT NULL CHECK (disaggregation_strength_index BETWEEN 0 AND 1),
    equity_visibility_index REAL NOT NULL CHECK (equity_visibility_index BETWEEN 0 AND 1),
    uncertainty_transparency_index REAL NOT NULL CHECK (uncertainty_transparency_index BETWEEN 0 AND 1),
    action_linkage_index REAL NOT NULL CHECK (action_linkage_index BETWEEN 0 AND 1),
    community_validation_index REAL NOT NULL CHECK (community_validation_index BETWEEN 0 AND 1),
    governance_accountability_index REAL NOT NULL CHECK (governance_accountability_index BETWEEN 0 AND 1),
    threshold_clarity_index REAL NOT NULL CHECK (threshold_clarity_index BETWEEN 0 AND 1),
    stress_performance_integration_index REAL NOT NULL CHECK (stress_performance_integration_index BETWEEN 0 AND 1),
    false_precision_risk_index REAL NOT NULL CHECK (false_precision_risk_index BETWEEN 0 AND 1),
    proxy_dependence_index REAL NOT NULL CHECK (proxy_dependence_index BETWEEN 0 AND 1),
    missing_data_risk_index REAL NOT NULL CHECK (missing_data_risk_index BETWEEN 0 AND 1),
    aggregation_loss_index REAL NOT NULL CHECK (aggregation_loss_index BETWEEN 0 AND 1),
    scale_boundary_error_index REAL NOT NULL CHECK (scale_boundary_error_index BETWEEN 0 AND 1),
    dashboard_theater_risk_index REAL NOT NULL CHECK (dashboard_theater_risk_index BETWEEN 0 AND 1),
    blind_spot_severity_index REAL NOT NULL CHECK (blind_spot_severity_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS resilience_dashboard_blind_spots_view AS
SELECT
    dashboard_id,
    dashboard_name,
    jurisdiction,
    dashboard_type,

    (
        0.12 * indicator_coverage_index +
        0.10 * dashboard_usability_index +
        0.11 * data_quality_index +
        0.08 * update_frequency_index +
        0.11 * disaggregation_strength_index +
        0.10 * equity_visibility_index +
        0.10 * uncertainty_transparency_index +
        0.10 * action_linkage_index +
        0.08 * community_validation_index +
        0.10 * governance_accountability_index +
        0.05 * threshold_clarity_index +
        0.05 * stress_performance_integration_index
    ) AS dashboard_strength_score,

    (
        0.16 * false_precision_risk_index +
        0.15 * proxy_dependence_index +
        0.15 * missing_data_risk_index +
        0.14 * aggregation_loss_index +
        0.13 * scale_boundary_error_index +
        0.13 * dashboard_theater_risk_index +
        0.14 * blind_spot_severity_index
    ) AS blind_spot_risk_score,

    (
        0.24 * action_linkage_index +
        0.20 * governance_accountability_index +
        0.18 * threshold_clarity_index +
        0.16 * stress_performance_integration_index +
        0.12 * update_frequency_index +
        0.10 * dashboard_usability_index
    ) AS dashboard_actionability_score

FROM resilience_dashboard_blind_spots_panel;

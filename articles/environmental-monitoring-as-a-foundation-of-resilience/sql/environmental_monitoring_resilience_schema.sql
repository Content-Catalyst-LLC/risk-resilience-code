-- Environmental Monitoring as a Foundation of Resilience Schema

CREATE TABLE IF NOT EXISTS environmental_monitoring_resilience_panel (
    monitoring_system_id INTEGER PRIMARY KEY,
    monitoring_system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_domain TEXT NOT NULL,

    observation_coverage_index REAL NOT NULL CHECK (observation_coverage_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    timeliness_index REAL NOT NULL CHECK (timeliness_index BETWEEN 0 AND 1),
    interoperability_index REAL NOT NULL CHECK (interoperability_index BETWEEN 0 AND 1),
    analytical_capacity_index REAL NOT NULL CHECK (analytical_capacity_index BETWEEN 0 AND 1),
    warning_dissemination_index REAL NOT NULL CHECK (warning_dissemination_index BETWEEN 0 AND 1),
    community_validation_index REAL NOT NULL CHECK (community_validation_index BETWEEN 0 AND 1),
    action_linkage_index REAL NOT NULL CHECK (action_linkage_index BETWEEN 0 AND 1),
    rights_safeguard_index REAL NOT NULL CHECK (rights_safeguard_index BETWEEN 0 AND 1),

    blind_spot_index REAL NOT NULL CHECK (blind_spot_index BETWEEN 0 AND 1),
    uncertainty_burden_index REAL NOT NULL CHECK (uncertainty_burden_index BETWEEN 0 AND 1),
    decision_lag_index REAL NOT NULL CHECK (decision_lag_index BETWEEN 0 AND 1),
    maintenance_risk_index REAL NOT NULL CHECK (maintenance_risk_index BETWEEN 0 AND 1),
    misuse_risk_index REAL NOT NULL CHECK (misuse_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS monitoring_action_triggers (
    trigger_id INTEGER PRIMARY KEY,
    monitoring_system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_domain TEXT NOT NULL,
    trigger_name TEXT NOT NULL,
    observed_variable TEXT NOT NULL,
    trigger_threshold TEXT NOT NULL,
    responsible_institution TEXT,
    required_action TEXT,
    communication_channel TEXT,
    review_frequency TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS environmental_monitoring_resilience_view AS
SELECT
    monitoring_system_id,
    monitoring_system_name,
    jurisdiction,
    system_domain,

    (
        0.15 * observation_coverage_index +
        0.14 * data_quality_index +
        0.13 * timeliness_index +
        0.12 * interoperability_index +
        0.12 * analytical_capacity_index +
        0.11 * warning_dissemination_index +
        0.09 * community_validation_index +
        0.09 * action_linkage_index +
        0.05 * rights_safeguard_index
    ) AS monitoring_capacity_score,

    (
        0.24 * blind_spot_index +
        0.20 * uncertainty_burden_index +
        0.20 * decision_lag_index +
        0.18 * maintenance_risk_index +
        0.18 * misuse_risk_index
    ) AS monitoring_risk_pressure_score,

    (
        (
            0.15 * observation_coverage_index +
            0.14 * data_quality_index +
            0.13 * timeliness_index +
            0.12 * interoperability_index +
            0.12 * analytical_capacity_index +
            0.11 * warning_dissemination_index +
            0.09 * community_validation_index +
            0.09 * action_linkage_index +
            0.05 * rights_safeguard_index
        )
        - action_linkage_index
    ) AS monitoring_action_gap

FROM environmental_monitoring_resilience_panel;

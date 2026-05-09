-- Efficiency, Slack, and Resilience in System Design Schema

CREATE TABLE IF NOT EXISTS efficiency_slack_resilience_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    system_type TEXT NOT NULL,

    routine_efficiency_index REAL NOT NULL CHECK (routine_efficiency_index BETWEEN 0 AND 1),
    protective_slack_index REAL NOT NULL CHECK (protective_slack_index BETWEEN 0 AND 1),
    redundancy_index REAL NOT NULL CHECK (redundancy_index BETWEEN 0 AND 1),
    modularity_index REAL NOT NULL CHECK (modularity_index BETWEEN 0 AND 1),
    diversity_index REAL NOT NULL CHECK (diversity_index BETWEEN 0 AND 1),
    feedback_monitoring_index REAL NOT NULL CHECK (feedback_monitoring_index BETWEEN 0 AND 1),
    repair_capacity_index REAL NOT NULL CHECK (repair_capacity_index BETWEEN 0 AND 1),
    governance_quality_index REAL NOT NULL CHECK (governance_quality_index BETWEEN 0 AND 1),

    tight_coupling_index REAL NOT NULL CHECK (tight_coupling_index BETWEEN 0 AND 1),
    single_point_dependence_index REAL NOT NULL CHECK (single_point_dependence_index BETWEEN 0 AND 1),
    overload_index REAL NOT NULL CHECK (overload_index BETWEEN 0 AND 1),
    deferred_maintenance_index REAL NOT NULL CHECK (deferred_maintenance_index BETWEEN 0 AND 1),
    hidden_risk_transfer_index REAL NOT NULL CHECK (hidden_risk_transfer_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS protective_slack_inventory (
    slack_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    slack_type TEXT NOT NULL,
    protected_function TEXT NOT NULL,
    available_capacity_description TEXT,
    activation_trigger TEXT,
    responsible_institution TEXT,
    justice_relevance TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS optimization_fragility_controls (
    control_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    fragility_mechanism TEXT NOT NULL,
    control_measure TEXT NOT NULL,
    monitoring_indicator TEXT,
    corrective_action TEXT,
    review_frequency TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS efficiency_slack_resilience_view AS
SELECT
    system_id,
    system_name,
    sector,
    system_type,

    (
        0.12 * routine_efficiency_index +
        0.16 * protective_slack_index +
        0.14 * redundancy_index +
        0.13 * modularity_index +
        0.12 * diversity_index +
        0.12 * feedback_monitoring_index +
        0.11 * repair_capacity_index +
        0.10 * governance_quality_index
    ) AS resilience_capacity_score,

    (
        0.22 * tight_coupling_index +
        0.22 * single_point_dependence_index +
        0.20 * overload_index +
        0.18 * deferred_maintenance_index +
        0.18 * hidden_risk_transfer_index
    ) AS optimization_fragility_pressure_score,

    (
        (
            0.12 * routine_efficiency_index +
            0.16 * protective_slack_index +
            0.14 * redundancy_index +
            0.13 * modularity_index +
            0.12 * diversity_index +
            0.12 * feedback_monitoring_index +
            0.11 * repair_capacity_index +
            0.10 * governance_quality_index
        )
        -
        (
            0.22 * tight_coupling_index +
            0.22 * single_point_dependence_index +
            0.20 * overload_index +
            0.18 * deferred_maintenance_index +
            0.18 * hidden_risk_transfer_index
        )
    ) AS slack_fragility_gap

FROM efficiency_slack_resilience_panel;

-- Planetary Boundaries and Global System Risk Schema

CREATE TABLE IF NOT EXISTS planetary_boundaries_risk_panel (
    boundary_id INTEGER PRIMARY KEY,
    boundary_name TEXT NOT NULL,
    earth_system_domain TEXT NOT NULL,
    boundary_status TEXT NOT NULL,

    boundary_transgression_index REAL NOT NULL CHECK (boundary_transgression_index BETWEEN 0 AND 1),
    pressure_trend_index REAL NOT NULL CHECK (pressure_trend_index BETWEEN 0 AND 1),
    interaction_strength_index REAL NOT NULL CHECK (interaction_strength_index BETWEEN 0 AND 1),
    reversibility_risk_index REAL NOT NULL CHECK (reversibility_risk_index BETWEEN 0 AND 1),
    human_system_exposure_index REAL NOT NULL CHECK (human_system_exposure_index BETWEEN 0 AND 1),

    monitoring_confidence_index REAL NOT NULL CHECK (monitoring_confidence_index BETWEEN 0 AND 1),
    adaptive_capacity_index REAL NOT NULL CHECK (adaptive_capacity_index BETWEEN 0 AND 1),
    governance_quality_index REAL NOT NULL CHECK (governance_quality_index BETWEEN 0 AND 1),
    justice_transition_index REAL NOT NULL CHECK (justice_transition_index BETWEEN 0 AND 1),
    policy_response_index REAL NOT NULL CHECK (policy_response_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS planetary_boundary_interactions (
    interaction_id INTEGER PRIMARY KEY,
    source_boundary TEXT NOT NULL,
    target_boundary TEXT NOT NULL,
    interaction_type TEXT NOT NULL,
    interaction_strength_index REAL NOT NULL CHECK (interaction_strength_index BETWEEN 0 AND 1),
    feedback_direction TEXT,
    reversibility_notes TEXT,
    governance_implication TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS planetary_transition_actions (
    action_id INTEGER PRIMARY KEY,
    action_name TEXT NOT NULL,
    boundary_domain TEXT NOT NULL,
    action_type TEXT NOT NULL,
    mitigation_component INTEGER CHECK (mitigation_component IN (0, 1)),
    adaptation_component INTEGER CHECK (adaptation_component IN (0, 1)),
    justice_component INTEGER CHECK (justice_component IN (0, 1)),
    monitoring_component INTEGER CHECK (monitoring_component IN (0, 1)),
    governance_component INTEGER CHECK (governance_component IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS planetary_boundaries_risk_view AS
SELECT
    boundary_id,
    boundary_name,
    earth_system_domain,
    boundary_status,

    (
        0.26 * boundary_transgression_index +
        0.22 * pressure_trend_index +
        0.20 * interaction_strength_index +
        0.18 * reversibility_risk_index +
        0.14 * human_system_exposure_index
    ) AS planetary_pressure_score,

    (
        0.22 * adaptive_capacity_index +
        0.22 * governance_quality_index +
        0.18 * justice_transition_index +
        0.18 * policy_response_index +
        0.20 * monitoring_confidence_index
    ) AS response_capacity_score,

    (
        (
            0.22 * adaptive_capacity_index +
            0.22 * governance_quality_index +
            0.18 * justice_transition_index +
            0.18 * policy_response_index +
            0.20 * monitoring_confidence_index
        )
        -
        (
            0.26 * boundary_transgression_index +
            0.22 * pressure_trend_index +
            0.20 * interaction_strength_index +
            0.18 * reversibility_risk_index +
            0.14 * human_system_exposure_index
        )
    ) AS earth_system_resilience_margin

FROM planetary_boundaries_risk_panel;

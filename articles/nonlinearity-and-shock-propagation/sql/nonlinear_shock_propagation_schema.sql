-- Nonlinearity and Shock Propagation Schema

CREATE TABLE IF NOT EXISTS nonlinear_shock_propagation_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    shock_type TEXT NOT NULL,

    shock_intensity_index REAL NOT NULL CHECK (shock_intensity_index BETWEEN 0 AND 1),
    threshold_proximity_index REAL NOT NULL CHECK (threshold_proximity_index BETWEEN 0 AND 1),
    network_centrality_index REAL NOT NULL CHECK (network_centrality_index BETWEEN 0 AND 1),
    coupling_strength_index REAL NOT NULL CHECK (coupling_strength_index BETWEEN 0 AND 1),
    feedback_amplification_index REAL NOT NULL CHECK (feedback_amplification_index BETWEEN 0 AND 1),
    hidden_stress_index REAL NOT NULL CHECK (hidden_stress_index BETWEEN 0 AND 1),
    exposure_inequality_index REAL NOT NULL CHECK (exposure_inequality_index BETWEEN 0 AND 1),

    buffering_capacity_index REAL NOT NULL CHECK (buffering_capacity_index BETWEEN 0 AND 1),
    modularity_index REAL NOT NULL CHECK (modularity_index BETWEEN 0 AND 1),
    redundancy_index REAL NOT NULL CHECK (redundancy_index BETWEEN 0 AND 1),
    adaptive_response_index REAL NOT NULL CHECK (adaptive_response_index BETWEEN 0 AND 1),
    governance_quality_index REAL NOT NULL CHECK (governance_quality_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS propagation_pathways (
    pathway_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    origin_node TEXT NOT NULL,
    propagation_channel TEXT NOT NULL,
    affected_system TEXT NOT NULL,
    secondary_effect TEXT,
    tertiary_effect TEXT,
    containment_measure TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS critical_nodes (
    node_id INTEGER PRIMARY KEY,
    node_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    node_type TEXT NOT NULL,
    dependency_description TEXT,
    failure_consequence TEXT,
    redundancy_available INTEGER CHECK (redundancy_available IN (0, 1)),
    containment_priority TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS nonlinear_shock_propagation_view AS
SELECT
    system_id,
    system_name,
    sector,
    shock_type,

    (
        0.16 * shock_intensity_index +
        0.18 * threshold_proximity_index +
        0.16 * network_centrality_index +
        0.16 * coupling_strength_index +
        0.14 * feedback_amplification_index +
        0.10 * hidden_stress_index +
        0.10 * exposure_inequality_index
    ) AS propagation_pressure_score,

    (
        0.22 * buffering_capacity_index +
        0.20 * modularity_index +
        0.20 * redundancy_index +
        0.20 * adaptive_response_index +
        0.18 * governance_quality_index
    ) AS containment_capacity_score,

    (
        (
            0.22 * buffering_capacity_index +
            0.20 * modularity_index +
            0.20 * redundancy_index +
            0.20 * adaptive_response_index +
            0.18 * governance_quality_index
        )
        -
        (
            0.16 * shock_intensity_index +
            0.18 * threshold_proximity_index +
            0.16 * network_centrality_index +
            0.16 * coupling_strength_index +
            0.14 * feedback_amplification_index +
            0.10 * hidden_stress_index +
            0.10 * exposure_inequality_index
        )
    ) AS propagation_resilience_margin

FROM nonlinear_shock_propagation_panel;

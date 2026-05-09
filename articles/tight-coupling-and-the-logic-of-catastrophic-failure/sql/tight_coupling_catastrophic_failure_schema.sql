-- Tight Coupling and the Logic of Catastrophic Failure Schema

CREATE TABLE IF NOT EXISTS tight_coupling_catastrophic_failure_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    system_type TEXT NOT NULL,

    coupling_strength_index REAL NOT NULL CHECK (coupling_strength_index BETWEEN 0 AND 1),
    time_compression_index REAL NOT NULL CHECK (time_compression_index BETWEEN 0 AND 1),
    sequence_rigidity_index REAL NOT NULL CHECK (sequence_rigidity_index BETWEEN 0 AND 1),
    limited_substitution_index REAL NOT NULL CHECK (limited_substitution_index BETWEEN 0 AND 1),
    interactive_complexity_index REAL NOT NULL CHECK (interactive_complexity_index BETWEEN 0 AND 1),
    hidden_dependency_index REAL NOT NULL CHECK (hidden_dependency_index BETWEEN 0 AND 1),
    critical_node_importance_index REAL NOT NULL CHECK (critical_node_importance_index BETWEEN 0 AND 1),

    buffering_index REAL NOT NULL CHECK (buffering_index BETWEEN 0 AND 1),
    modularity_index REAL NOT NULL CHECK (modularity_index BETWEEN 0 AND 1),
    redundancy_index REAL NOT NULL CHECK (redundancy_index BETWEEN 0 AND 1),
    adaptive_authority_index REAL NOT NULL CHECK (adaptive_authority_index BETWEEN 0 AND 1),
    fallback_capacity_index REAL NOT NULL CHECK (fallback_capacity_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS coupling_dependencies (
    dependency_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    upstream_dependency TEXT NOT NULL,
    downstream_function TEXT NOT NULL,
    time_to_impact_minutes REAL,
    substitution_available INTEGER CHECK (substitution_available IN (0, 1)),
    fallback_available INTEGER CHECK (fallback_available IN (0, 1)),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS containment_controls (
    control_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    control_type TEXT NOT NULL,
    control_measure TEXT NOT NULL,
    protected_function TEXT NOT NULL,
    activation_trigger TEXT,
    responsible_actor TEXT,
    justice_relevance TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS tight_coupling_catastrophic_failure_view AS
SELECT
    system_id,
    system_name,
    sector,
    system_type,

    (
        0.16 * coupling_strength_index +
        0.16 * time_compression_index +
        0.14 * sequence_rigidity_index +
        0.13 * limited_substitution_index +
        0.15 * interactive_complexity_index +
        0.12 * hidden_dependency_index +
        0.14 * critical_node_importance_index
    ) AS tight_coupling_pressure_score,

    (
        0.22 * buffering_index +
        0.20 * modularity_index +
        0.20 * redundancy_index +
        0.20 * adaptive_authority_index +
        0.18 * fallback_capacity_index
    ) AS resilience_room_score,

    (
        (
            0.22 * buffering_index +
            0.20 * modularity_index +
            0.20 * redundancy_index +
            0.20 * adaptive_authority_index +
            0.18 * fallback_capacity_index
        )
        -
        (
            0.16 * coupling_strength_index +
            0.16 * time_compression_index +
            0.14 * sequence_rigidity_index +
            0.13 * limited_substitution_index +
            0.15 * interactive_complexity_index +
            0.12 * hidden_dependency_index +
            0.14 * critical_node_importance_index
        )
    ) AS containment_margin

FROM tight_coupling_catastrophic_failure_panel;

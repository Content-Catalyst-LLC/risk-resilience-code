-- Path Dependence, Lock-In, and Resilience Traps Schema

CREATE TABLE IF NOT EXISTS path_dependence_lock_in_resilience_traps_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    pathway_type TEXT NOT NULL,

    sunk_cost_index REAL NOT NULL CHECK (sunk_cost_index BETWEEN 0 AND 1),
    infrastructure_rigidity_index REAL NOT NULL CHECK (infrastructure_rigidity_index BETWEEN 0 AND 1),
    institutional_inertia_index REAL NOT NULL CHECK (institutional_inertia_index BETWEEN 0 AND 1),
    incumbent_power_index REAL NOT NULL CHECK (incumbent_power_index BETWEEN 0 AND 1),
    social_dependence_index REAL NOT NULL CHECK (social_dependence_index BETWEEN 0 AND 1),
    technological_incompatibility_index REAL NOT NULL CHECK (technological_incompatibility_index BETWEEN 0 AND 1),
    ecological_feedback_index REAL NOT NULL CHECK (ecological_feedback_index BETWEEN 0 AND 1),

    alternative_capacity_index REAL NOT NULL CHECK (alternative_capacity_index BETWEEN 0 AND 1),
    adaptive_governance_index REAL NOT NULL CHECK (adaptive_governance_index BETWEEN 0 AND 1),
    public_legitimacy_index REAL NOT NULL CHECK (public_legitimacy_index BETWEEN 0 AND 1),
    justice_transition_index REAL NOT NULL CHECK (justice_transition_index BETWEEN 0 AND 1),
    reversibility_index REAL NOT NULL CHECK (reversibility_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS lock_in_feedbacks (
    feedback_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    feedback_type TEXT NOT NULL,
    reinforcing_mechanism TEXT NOT NULL,
    affected_groups TEXT,
    ecological_or_social_cost TEXT,
    potential_intervention TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS transformation_options (
    option_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    option_name TEXT NOT NULL,
    intervention_type TEXT NOT NULL,
    alternative_capacity_component INTEGER CHECK (alternative_capacity_component IN (0, 1)),
    adaptive_governance_component INTEGER CHECK (adaptive_governance_component IN (0, 1)),
    justice_transition_component INTEGER CHECK (justice_transition_component IN (0, 1)),
    reversibility_component INTEGER CHECK (reversibility_component IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS path_dependence_lock_in_resilience_traps_view AS
SELECT
    system_id,
    system_name,
    sector,
    pathway_type,

    (
        0.16 * sunk_cost_index +
        0.16 * infrastructure_rigidity_index +
        0.16 * institutional_inertia_index +
        0.16 * incumbent_power_index +
        0.14 * social_dependence_index +
        0.11 * technological_incompatibility_index +
        0.11 * ecological_feedback_index
    ) AS lock_in_pressure_score,

    (
        0.22 * alternative_capacity_index +
        0.22 * adaptive_governance_index +
        0.18 * public_legitimacy_index +
        0.20 * justice_transition_index +
        0.18 * reversibility_index
    ) AS transformation_capacity_score,

    (
        (
            0.22 * alternative_capacity_index +
            0.22 * adaptive_governance_index +
            0.18 * public_legitimacy_index +
            0.20 * justice_transition_index +
            0.18 * reversibility_index
        )
        -
        (
            0.16 * sunk_cost_index +
            0.16 * infrastructure_rigidity_index +
            0.16 * institutional_inertia_index +
            0.16 * incumbent_power_index +
            0.14 * social_dependence_index +
            0.11 * technological_incompatibility_index +
            0.11 * ecological_feedback_index
        )
    ) AS escape_gap

FROM path_dependence_lock_in_resilience_traps_panel;

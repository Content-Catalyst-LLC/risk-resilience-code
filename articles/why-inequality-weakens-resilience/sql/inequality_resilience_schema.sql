-- Why Inequality Weakens Resilience Schema
-- Article: Why Inequality Weakens Resilience

CREATE TABLE IF NOT EXISTS inequality_resilience_panel (
    place_id INTEGER PRIMARY KEY,
    place_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    place_type TEXT NOT NULL,

    system_capacity_index REAL NOT NULL CHECK (system_capacity_index BETWEEN 0 AND 1),
    distributed_protection_index REAL NOT NULL CHECK (distributed_protection_index BETWEEN 0 AND 1),
    household_buffer_index REAL NOT NULL CHECK (household_buffer_index BETWEEN 0 AND 1),
    service_access_index REAL NOT NULL CHECK (service_access_index BETWEEN 0 AND 1),
    institutional_trust_index REAL NOT NULL CHECK (institutional_trust_index BETWEEN 0 AND 1),
    adaptive_capacity_index REAL NOT NULL CHECK (adaptive_capacity_index BETWEEN 0 AND 1),
    social_protection_index REAL NOT NULL CHECK (social_protection_index BETWEEN 0 AND 1),
    community_voice_index REAL NOT NULL CHECK (community_voice_index BETWEEN 0 AND 1),

    exposure_concentration_index REAL NOT NULL CHECK (exposure_concentration_index BETWEEN 0 AND 1),
    multidimensional_deprivation_index REAL NOT NULL CHECK (multidimensional_deprivation_index BETWEEN 0 AND 1),
    social_exclusion_index REAL NOT NULL CHECK (social_exclusion_index BETWEEN 0 AND 1),
    recovery_inequality_index REAL NOT NULL CHECK (recovery_inequality_index BETWEEN 0 AND 1),
    digital_exclusion_index REAL NOT NULL CHECK (digital_exclusion_index BETWEEN 0 AND 1),
    fiscal_stress_index REAL NOT NULL CHECK (fiscal_stress_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS resilience_protection_programs (
    program_id INTEGER PRIMARY KEY,
    place_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    program_name TEXT NOT NULL,
    program_type TEXT NOT NULL,
    start_year INTEGER,
    social_protection_component INTEGER CHECK (social_protection_component IN (0, 1)),
    infrastructure_component INTEGER CHECK (infrastructure_component IN (0, 1)),
    housing_component INTEGER CHECK (housing_component IN (0, 1)),
    health_component INTEGER CHECK (health_component IN (0, 1)),
    community_voice_component INTEGER CHECK (community_voice_component IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS inequality_resilience_view AS
SELECT
    place_id,
    place_name,
    jurisdiction,
    place_type,

    (
        0.22 * system_capacity_index +
        0.18 * service_access_index +
        0.16 * adaptive_capacity_index +
        0.14 * social_protection_index +
        0.12 * institutional_trust_index +
        0.10 * household_buffer_index +
        0.08 * community_voice_index
    ) AS aggregate_resilience_capacity_score,

    (
        0.22 * exposure_concentration_index +
        0.20 * multidimensional_deprivation_index +
        0.18 * social_exclusion_index +
        0.16 * recovery_inequality_index +
        0.13 * digital_exclusion_index +
        0.11 * fiscal_stress_index
    ) AS inequality_pressure_score,

    (
        distributed_protection_index - exposure_concentration_index
    ) AS protection_gap

FROM inequality_resilience_panel;

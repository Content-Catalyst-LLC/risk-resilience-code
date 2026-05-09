-- Regenerative Resilience and the Repair of Living Systems Schema
-- Article: Regenerative Resilience and the Repair of Living Systems

CREATE TABLE IF NOT EXISTS regenerative_resilience_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    ecosystem_integrity_index REAL NOT NULL CHECK (ecosystem_integrity_index BETWEEN 0 AND 1),
    biodiversity_index REAL NOT NULL CHECK (biodiversity_index BETWEEN 0 AND 1),
    soil_health_index REAL NOT NULL CHECK (soil_health_index BETWEEN 0 AND 1),
    water_function_index REAL NOT NULL CHECK (water_function_index BETWEEN 0 AND 1),
    connectivity_index REAL NOT NULL CHECK (connectivity_index BETWEEN 0 AND 1),
    local_stewardship_index REAL NOT NULL CHECK (local_stewardship_index BETWEEN 0 AND 1),
    governance_accountability_index REAL NOT NULL CHECK (governance_accountability_index BETWEEN 0 AND 1),
    justice_repair_index REAL NOT NULL CHECK (justice_repair_index BETWEEN 0 AND 1),
    monitoring_quality_index REAL NOT NULL CHECK (monitoring_quality_index BETWEEN 0 AND 1),

    degradation_pressure_index REAL NOT NULL CHECK (degradation_pressure_index BETWEEN 0 AND 1),
    fragmentation_pressure_index REAL NOT NULL CHECK (fragmentation_pressure_index BETWEEN 0 AND 1),
    extraction_pressure_index REAL NOT NULL CHECK (extraction_pressure_index BETWEEN 0 AND 1),
    pollution_pressure_index REAL NOT NULL CHECK (pollution_pressure_index BETWEEN 0 AND 1),
    climate_stress_index REAL NOT NULL CHECK (climate_stress_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS restoration_integrity_events (
    restoration_event_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    event_date TEXT NOT NULL,
    intervention_type TEXT NOT NULL,
    functional_recovery_index REAL CHECK (functional_recovery_index BETWEEN 0 AND 1),
    biodiversity_recovery_index REAL CHECK (biodiversity_recovery_index BETWEEN 0 AND 1),
    hydrological_repair_index REAL CHECK (hydrological_repair_index BETWEEN 0 AND 1),
    community_stewardship_index REAL CHECK (community_stewardship_index BETWEEN 0 AND 1),
    justice_outcome_index REAL CHECK (justice_outcome_index BETWEEN 0 AND 1),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS regenerative_resilience_view AS
SELECT
    system_id,
    system_name,
    jurisdiction,
    system_type,

    (
        0.15 * ecosystem_integrity_index +
        0.14 * biodiversity_index +
        0.14 * soil_health_index +
        0.13 * water_function_index +
        0.12 * connectivity_index +
        0.10 * local_stewardship_index +
        0.10 * governance_accountability_index +
        0.08 * justice_repair_index +
        0.04 * monitoring_quality_index
    ) AS regenerative_capacity_score,

    (
        0.20 * degradation_pressure_index +
        0.17 * fragmentation_pressure_index +
        0.16 * extraction_pressure_index +
        0.15 * pollution_pressure_index +
        0.18 * climate_stress_index +
        0.14 * maladaptation_risk_index
    ) AS degradation_pressure_score,

    (
        (
            0.15 * ecosystem_integrity_index +
            0.14 * biodiversity_index +
            0.14 * soil_health_index +
            0.13 * water_function_index +
            0.12 * connectivity_index +
            0.10 * local_stewardship_index +
            0.10 * governance_accountability_index +
            0.08 * justice_repair_index +
            0.04 * monitoring_quality_index
        )
        -
        (
            0.20 * degradation_pressure_index +
            0.17 * fragmentation_pressure_index +
            0.16 * extraction_pressure_index +
            0.15 * pollution_pressure_index +
            0.18 * climate_stress_index +
            0.14 * maladaptation_risk_index
        )
    ) AS living_systems_repair_gap

FROM regenerative_resilience_panel;

CREATE VIEW IF NOT EXISTS restoration_integrity_view AS
SELECT
    restoration_event_id,
    system_name,
    event_date,
    intervention_type,
    functional_recovery_index,
    biodiversity_recovery_index,
    hydrological_repair_index,
    community_stewardship_index,
    justice_outcome_index,

    (
        COALESCE(functional_recovery_index, 0.0) +
        COALESCE(biodiversity_recovery_index, 0.0) +
        COALESCE(hydrological_repair_index, 0.0) +
        COALESCE(community_stewardship_index, 0.0) +
        COALESCE(justice_outcome_index, 0.0)
    ) / 5.0 AS restoration_integrity_score

FROM restoration_integrity_events;

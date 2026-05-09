-- Biodiversity Loss and Ecological Resilience Schema
-- Article: Biodiversity Loss and Ecological Resilience

CREATE TABLE IF NOT EXISTS biodiversity_ecological_resilience_panel (
    ecosystem_id INTEGER PRIMARY KEY,
    ecosystem_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    ecosystem_type TEXT NOT NULL,

    genetic_diversity_index REAL NOT NULL CHECK (genetic_diversity_index BETWEEN 0 AND 1),
    species_diversity_index REAL NOT NULL CHECK (species_diversity_index BETWEEN 0 AND 1),
    functional_diversity_index REAL NOT NULL CHECK (functional_diversity_index BETWEEN 0 AND 1),
    habitat_connectivity_index REAL NOT NULL CHECK (habitat_connectivity_index BETWEEN 0 AND 1),
    ecosystem_integrity_index REAL NOT NULL CHECK (ecosystem_integrity_index BETWEEN 0 AND 1),
    adaptive_capacity_index REAL NOT NULL CHECK (adaptive_capacity_index BETWEEN 0 AND 1),
    governance_quality_index REAL NOT NULL CHECK (governance_quality_index BETWEEN 0 AND 1),
    community_stewardship_index REAL NOT NULL CHECK (community_stewardship_index BETWEEN 0 AND 1),

    fragmentation_pressure_index REAL NOT NULL CHECK (fragmentation_pressure_index BETWEEN 0 AND 1),
    pollution_pressure_index REAL NOT NULL CHECK (pollution_pressure_index BETWEEN 0 AND 1),
    invasive_pressure_index REAL NOT NULL CHECK (invasive_pressure_index BETWEEN 0 AND 1),
    extraction_pressure_index REAL NOT NULL CHECK (extraction_pressure_index BETWEEN 0 AND 1),
    climate_stress_index REAL NOT NULL CHECK (climate_stress_index BETWEEN 0 AND 1),
    monitoring_gap_index REAL NOT NULL CHECK (monitoring_gap_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS biodiversity_monitoring_events (
    monitoring_event_id INTEGER PRIMARY KEY,
    ecosystem_name TEXT NOT NULL,
    monitoring_date TEXT NOT NULL,
    monitoring_method TEXT NOT NULL,
    indicator_name TEXT NOT NULL,
    indicator_value REAL,
    confidence_index REAL CHECK (confidence_index BETWEEN 0 AND 1),
    observer_or_institution TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS biodiversity_ecological_resilience_view AS
SELECT
    ecosystem_id,
    ecosystem_name,
    jurisdiction,
    ecosystem_type,

    (
        0.15 * genetic_diversity_index +
        0.16 * species_diversity_index +
        0.17 * functional_diversity_index +
        0.15 * habitat_connectivity_index +
        0.15 * ecosystem_integrity_index +
        0.10 * adaptive_capacity_index +
        0.07 * governance_quality_index +
        0.05 * community_stewardship_index
    ) AS biodiversity_resilience_score,

    (
        0.18 * fragmentation_pressure_index +
        0.16 * pollution_pressure_index +
        0.16 * invasive_pressure_index +
        0.18 * extraction_pressure_index +
        0.20 * climate_stress_index +
        0.12 * monitoring_gap_index
    ) AS ecological_pressure_score,

    (
        (
            0.15 * genetic_diversity_index +
            0.16 * species_diversity_index +
            0.17 * functional_diversity_index +
            0.15 * habitat_connectivity_index +
            0.15 * ecosystem_integrity_index +
            0.10 * adaptive_capacity_index +
            0.07 * governance_quality_index +
            0.05 * community_stewardship_index
        )
        -
        (
            0.18 * fragmentation_pressure_index +
            0.16 * pollution_pressure_index +
            0.16 * invasive_pressure_index +
            0.18 * extraction_pressure_index +
            0.20 * climate_stress_index +
            0.12 * monitoring_gap_index
        )
    ) AS ecological_resilience_gap

FROM biodiversity_ecological_resilience_panel;

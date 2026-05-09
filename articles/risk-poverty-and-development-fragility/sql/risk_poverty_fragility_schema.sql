-- Risk, Poverty, and Development Fragility Schema
-- Article: Risk, Poverty, and Development Fragility

CREATE TABLE IF NOT EXISTS risk_poverty_development_fragility_panel (
    place_id INTEGER PRIMARY KEY,
    place_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    place_type TEXT NOT NULL,

    risk_exposure_index REAL NOT NULL CHECK (risk_exposure_index BETWEEN 0 AND 1),
    multidimensional_poverty_index REAL NOT NULL CHECK (multidimensional_poverty_index BETWEEN 0 AND 1),
    institutional_weakness_index REAL NOT NULL CHECK (institutional_weakness_index BETWEEN 0 AND 1),
    livelihood_precarity_index REAL NOT NULL CHECK (livelihood_precarity_index BETWEEN 0 AND 1),
    service_deficit_index REAL NOT NULL CHECK (service_deficit_index BETWEEN 0 AND 1),
    conflict_pressure_index REAL NOT NULL CHECK (conflict_pressure_index BETWEEN 0 AND 1),
    climate_stress_index REAL NOT NULL CHECK (climate_stress_index BETWEEN 0 AND 1),
    displacement_pressure_index REAL NOT NULL CHECK (displacement_pressure_index BETWEEN 0 AND 1),

    social_protection_index REAL NOT NULL CHECK (social_protection_index BETWEEN 0 AND 1),
    household_buffer_index REAL NOT NULL CHECK (household_buffer_index BETWEEN 0 AND 1),
    adaptive_capacity_index REAL NOT NULL CHECK (adaptive_capacity_index BETWEEN 0 AND 1),
    service_continuity_index REAL NOT NULL CHECK (service_continuity_index BETWEEN 0 AND 1),
    institutional_trust_index REAL NOT NULL CHECK (institutional_trust_index BETWEEN 0 AND 1),
    community_voice_index REAL NOT NULL CHECK (community_voice_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS poverty_fragility_interventions (
    intervention_id INTEGER PRIMARY KEY,
    place_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    intervention_name TEXT NOT NULL,
    intervention_type TEXT NOT NULL,
    start_year INTEGER,
    social_protection_component INTEGER CHECK (social_protection_component IN (0, 1)),
    service_delivery_component INTEGER CHECK (service_delivery_component IN (0, 1)),
    livelihood_component INTEGER CHECK (livelihood_component IN (0, 1)),
    climate_adaptation_component INTEGER CHECK (climate_adaptation_component IN (0, 1)),
    conflict_or_displacement_component INTEGER CHECK (conflict_or_displacement_component IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS risk_poverty_fragility_view AS
SELECT
    place_id,
    place_name,
    jurisdiction,
    place_type,

    (
        0.18 * risk_exposure_index +
        0.17 * multidimensional_poverty_index +
        0.15 * institutional_weakness_index +
        0.14 * livelihood_precarity_index +
        0.13 * service_deficit_index +
        0.10 * conflict_pressure_index +
        0.08 * climate_stress_index +
        0.05 * displacement_pressure_index
    ) AS development_fragility_score,

    (
        0.18 * social_protection_index +
        0.17 * household_buffer_index +
        0.17 * adaptive_capacity_index +
        0.16 * service_continuity_index +
        0.16 * institutional_trust_index +
        0.16 * community_voice_index
    ) AS resilience_sufficiency_score,

    (
        (
            0.18 * social_protection_index +
            0.17 * household_buffer_index +
            0.17 * adaptive_capacity_index +
            0.16 * service_continuity_index +
            0.16 * institutional_trust_index +
            0.16 * community_voice_index
        )
        -
        (
            0.18 * risk_exposure_index +
            0.17 * multidimensional_poverty_index +
            0.15 * institutional_weakness_index +
            0.14 * livelihood_precarity_index +
            0.13 * service_deficit_index +
            0.10 * conflict_pressure_index +
            0.08 * climate_stress_index +
            0.05 * displacement_pressure_index
        )
    ) AS poverty_fragility_gap

FROM risk_poverty_development_fragility_panel;

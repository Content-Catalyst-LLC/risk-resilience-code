-- Urbanization, Informality, and Risk Exposure Schema

CREATE TABLE IF NOT EXISTS urban_informality_risk_exposure_panel (
    settlement_id INTEGER PRIMARY KEY,
    settlement_name TEXT NOT NULL,
    city TEXT NOT NULL,
    country_or_region TEXT NOT NULL,
    settlement_type TEXT NOT NULL,

    flood_exposure_index REAL NOT NULL CHECK (flood_exposure_index BETWEEN 0 AND 1),
    heat_exposure_index REAL NOT NULL CHECK (heat_exposure_index BETWEEN 0 AND 1),
    landslide_or_fire_exposure_index REAL NOT NULL CHECK (landslide_or_fire_exposure_index BETWEEN 0 AND 1),
    housing_vulnerability_index REAL NOT NULL CHECK (housing_vulnerability_index BETWEEN 0 AND 1),
    infrastructure_deficit_index REAL NOT NULL CHECK (infrastructure_deficit_index BETWEEN 0 AND 1),
    service_access_index REAL NOT NULL CHECK (service_access_index BETWEEN 0 AND 1),
    tenure_security_index REAL NOT NULL CHECK (tenure_security_index BETWEEN 0 AND 1),
    livelihood_precarity_index REAL NOT NULL CHECK (livelihood_precarity_index BETWEEN 0 AND 1),
    social_protection_access_index REAL NOT NULL CHECK (social_protection_access_index BETWEEN 0 AND 1),
    community_adaptation_index REAL NOT NULL CHECK (community_adaptation_index BETWEEN 0 AND 1),
    institutional_protection_index REAL NOT NULL CHECK (institutional_protection_index BETWEEN 0 AND 1),
    climate_stress_index REAL NOT NULL CHECK (climate_stress_index BETWEEN 0 AND 1),
    displacement_pressure_index REAL NOT NULL CHECK (displacement_pressure_index BETWEEN 0 AND 1),
    data_visibility_index REAL NOT NULL CHECK (data_visibility_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS urban_upgrading_projects (
    project_id INTEGER PRIMARY KEY,
    settlement_name TEXT NOT NULL,
    city TEXT NOT NULL,
    project_name TEXT NOT NULL,
    project_type TEXT NOT NULL,
    start_year INTEGER,
    end_year INTEGER,
    community_led INTEGER CHECK (community_led IN (0, 1)),
    tenure_component INTEGER CHECK (tenure_component IN (0, 1)),
    service_component INTEGER CHECK (service_component IN (0, 1)),
    climate_component INTEGER CHECK (climate_component IN (0, 1)),
    displacement_safeguard INTEGER CHECK (displacement_safeguard IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS urban_informality_risk_view AS
SELECT
    settlement_id,
    settlement_name,
    city,
    country_or_region,
    settlement_type,

    (
        0.38 * flood_exposure_index +
        0.34 * heat_exposure_index +
        0.28 * landslide_or_fire_exposure_index
    ) AS hazard_exposure_score,

    (
        0.24 * housing_vulnerability_index +
        0.22 * infrastructure_deficit_index +
        0.18 * livelihood_precarity_index +
        0.14 * (1 - tenure_security_index) +
        0.12 * displacement_pressure_index +
        0.10 * (1 - social_protection_access_index)
    ) AS urban_vulnerability_score,

    (
        0.18 * service_access_index +
        0.16 * tenure_security_index +
        0.16 * community_adaptation_index +
        0.15 * institutional_protection_index +
        0.13 * social_protection_access_index +
        0.12 * data_visibility_index +
        0.10 * (1 - infrastructure_deficit_index)
    ) AS inclusive_protection_capacity_score

FROM urban_informality_risk_exposure_panel;

-- Energy Security, Grid Fragility, and Resilience Schema

CREATE TABLE IF NOT EXISTS energy_security_grid_resilience_panel (
    energy_system_id INTEGER PRIMARY KEY,
    energy_system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    reliability_index REAL NOT NULL CHECK (reliability_index BETWEEN 0 AND 1),
    adequacy_index REAL NOT NULL CHECK (adequacy_index BETWEEN 0 AND 1),
    redundancy_index REAL NOT NULL CHECK (redundancy_index BETWEEN 0 AND 1),
    flexibility_index REAL NOT NULL CHECK (flexibility_index BETWEEN 0 AND 1),
    distributed_capacity_index REAL NOT NULL CHECK (distributed_capacity_index BETWEEN 0 AND 1),
    cyber_resilience_index REAL NOT NULL CHECK (cyber_resilience_index BETWEEN 0 AND 1),
    restoration_capacity_index REAL NOT NULL CHECK (restoration_capacity_index BETWEEN 0 AND 1),
    critical_load_protection_index REAL NOT NULL CHECK (critical_load_protection_index BETWEEN 0 AND 1),
    affordability_index REAL NOT NULL CHECK (affordability_index BETWEEN 0 AND 1),
    equity_protection_index REAL NOT NULL CHECK (equity_protection_index BETWEEN 0 AND 1),

    climate_exposure_index REAL NOT NULL CHECK (climate_exposure_index BETWEEN 0 AND 1),
    infrastructure_aging_index REAL NOT NULL CHECK (infrastructure_aging_index BETWEEN 0 AND 1),
    fuel_dependence_index REAL NOT NULL CHECK (fuel_dependence_index BETWEEN 0 AND 1),
    digital_fragility_index REAL NOT NULL CHECK (digital_fragility_index BETWEEN 0 AND 1),
    load_growth_pressure_index REAL NOT NULL CHECK (load_growth_pressure_index BETWEEN 0 AND 1),
    interdependency_risk_index REAL NOT NULL CHECK (interdependency_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS critical_energy_loads (
    critical_load_id INTEGER PRIMARY KEY,
    facility_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    load_type TEXT NOT NULL,
    service_function TEXT NOT NULL,
    backup_power_available INTEGER CHECK (backup_power_available IN (0, 1)),
    backup_duration_hours REAL,
    microgrid_candidate INTEGER CHECK (microgrid_candidate IN (0, 1)),
    restoration_priority TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS grid_resilience_investments (
    investment_id INTEGER PRIMARY KEY,
    investment_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    investment_type TEXT NOT NULL,
    climate_resilience_component INTEGER CHECK (climate_resilience_component IN (0, 1)),
    cyber_resilience_component INTEGER CHECK (cyber_resilience_component IN (0, 1)),
    distributed_energy_component INTEGER CHECK (distributed_energy_component IN (0, 1)),
    equity_component INTEGER CHECK (equity_component IN (0, 1)),
    critical_load_component INTEGER CHECK (critical_load_component IN (0, 1)),
    notes TEXT
);

CREATE VIEW IF NOT EXISTS energy_security_grid_resilience_view AS
SELECT
    energy_system_id,
    energy_system_name,
    jurisdiction,
    system_type,

    (
        0.14 * reliability_index +
        0.13 * adequacy_index +
        0.13 * redundancy_index +
        0.12 * flexibility_index +
        0.11 * distributed_capacity_index +
        0.11 * cyber_resilience_index +
        0.13 * restoration_capacity_index +
        0.13 * critical_load_protection_index
    ) AS energy_resilience_capacity_score,

    (
        0.18 * climate_exposure_index +
        0.17 * infrastructure_aging_index +
        0.15 * fuel_dependence_index +
        0.15 * digital_fragility_index +
        0.18 * load_growth_pressure_index +
        0.17 * interdependency_risk_index
    ) AS grid_fragility_pressure_score,

    (
        0.24 * affordability_index +
        0.24 * equity_protection_index +
        0.22 * critical_load_protection_index +
        0.16 * distributed_capacity_index +
        0.14 * restoration_capacity_index
    ) AS just_energy_resilience_score

FROM energy_security_grid_resilience_panel;

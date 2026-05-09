-- Clean Drinking Water, Desalination, and Water-Supply Resilience Schema

CREATE TABLE IF NOT EXISTS drinking_water_resilience_panel (
    water_system_id INTEGER PRIMARY KEY,
    water_system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    source_protection_index REAL NOT NULL CHECK (source_protection_index BETWEEN 0 AND 1),
    treatment_capacity_index REAL NOT NULL CHECK (treatment_capacity_index BETWEEN 0 AND 1),
    distribution_reliability_index REAL NOT NULL CHECK (distribution_reliability_index BETWEEN 0 AND 1),
    monitoring_quality_index REAL NOT NULL CHECK (monitoring_quality_index BETWEEN 0 AND 1),
    supply_diversity_index REAL NOT NULL CHECK (supply_diversity_index BETWEEN 0 AND 1),
    energy_resilience_index REAL NOT NULL CHECK (energy_resilience_index BETWEEN 0 AND 1),
    affordability_index REAL NOT NULL CHECK (affordability_index BETWEEN 0 AND 1),
    governance_capacity_index REAL NOT NULL CHECK (governance_capacity_index BETWEEN 0 AND 1),

    contamination_risk_index REAL NOT NULL CHECK (contamination_risk_index BETWEEN 0 AND 1),
    infrastructure_aging_index REAL NOT NULL CHECK (infrastructure_aging_index BETWEEN 0 AND 1),
    salinity_pressure_index REAL NOT NULL CHECK (salinity_pressure_index BETWEEN 0 AND 1),
    energy_dependence_index REAL NOT NULL CHECK (energy_dependence_index BETWEEN 0 AND 1),
    brine_burden_index REAL NOT NULL CHECK (brine_burden_index BETWEEN 0 AND 1),
    access_inequality_index REAL NOT NULL CHECK (access_inequality_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_source TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS desalination_facilities (
    facility_id INTEGER PRIMARY KEY,
    facility_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    desalination_type TEXT NOT NULL,
    feedwater_type TEXT NOT NULL,
    design_capacity_mgd REAL,
    renewable_energy_component INTEGER CHECK (renewable_energy_component IN (0, 1)),
    brine_management_strategy TEXT,
    affordability_protection INTEGER CHECK (affordability_protection IN (0, 1)),
    marine_monitoring_required INTEGER CHECK (marine_monitoring_required IN (0, 1)),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS water_safety_controls (
    control_id INTEGER PRIMARY KEY,
    water_system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    control_point TEXT NOT NULL,
    hazard_type TEXT NOT NULL,
    control_measure TEXT NOT NULL,
    monitoring_indicator TEXT,
    corrective_action TEXT,
    responsible_institution TEXT,
    review_frequency TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS drinking_water_resilience_view AS
SELECT
    water_system_id,
    water_system_name,
    jurisdiction,
    system_type,

    (
        0.15 * source_protection_index +
        0.16 * treatment_capacity_index +
        0.15 * distribution_reliability_index +
        0.14 * monitoring_quality_index +
        0.11 * supply_diversity_index +
        0.10 * energy_resilience_index +
        0.09 * affordability_index +
        0.10 * governance_capacity_index
    ) AS water_resilience_capacity_score,

    (
        0.22 * contamination_risk_index +
        0.18 * infrastructure_aging_index +
        0.16 * salinity_pressure_index +
        0.15 * energy_dependence_index +
        0.13 * brine_burden_index +
        0.16 * access_inequality_index
    ) AS water_system_risk_pressure_score,

    (
        (
            0.15 * source_protection_index +
            0.16 * treatment_capacity_index +
            0.15 * distribution_reliability_index +
            0.14 * monitoring_quality_index +
            0.11 * supply_diversity_index +
            0.10 * energy_resilience_index +
            0.09 * affordability_index +
            0.10 * governance_capacity_index
        )
        -
        (
            0.22 * contamination_risk_index +
            0.18 * infrastructure_aging_index +
            0.16 * salinity_pressure_index +
            0.15 * energy_dependence_index +
            0.13 * brine_burden_index +
            0.16 * access_inequality_index
        )
    ) AS source_to_tap_resilience_gap

FROM drinking_water_resilience_panel;

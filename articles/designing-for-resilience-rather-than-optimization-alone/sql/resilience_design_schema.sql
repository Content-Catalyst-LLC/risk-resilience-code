CREATE TABLE IF NOT EXISTS resilience_design_system_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    system_type TEXT NOT NULL,

    normal_performance_index REAL NOT NULL CHECK (normal_performance_index BETWEEN 0 AND 1),
    cost_efficiency_index REAL NOT NULL CHECK (cost_efficiency_index BETWEEN 0 AND 1),
    utilization_pressure_index REAL NOT NULL CHECK (utilization_pressure_index BETWEEN 0 AND 1),
    slack_capacity_index REAL NOT NULL CHECK (slack_capacity_index BETWEEN 0 AND 1),
    redundancy_capacity_index REAL NOT NULL CHECK (redundancy_capacity_index BETWEEN 0 AND 1),
    flexibility_capacity_index REAL NOT NULL CHECK (flexibility_capacity_index BETWEEN 0 AND 1),
    modularity_index REAL NOT NULL CHECK (modularity_index BETWEEN 0 AND 1),
    dependency_visibility_index REAL NOT NULL CHECK (dependency_visibility_index BETWEEN 0 AND 1),
    dependency_concentration_index REAL NOT NULL CHECK (dependency_concentration_index BETWEEN 0 AND 1),
    tight_coupling_index REAL NOT NULL CHECK (tight_coupling_index BETWEEN 0 AND 1),
    maintenance_vulnerability_index REAL NOT NULL CHECK (maintenance_vulnerability_index BETWEEN 0 AND 1),
    cyber_exposure_index REAL NOT NULL CHECK (cyber_exposure_index BETWEEN 0 AND 1),
    climate_hazard_exposure_index REAL NOT NULL CHECK (climate_hazard_exposure_index BETWEEN 0 AND 1),
    service_criticality_index REAL NOT NULL CHECK (service_criticality_index BETWEEN 0 AND 1),
    governance_capacity_index REAL NOT NULL CHECK (governance_capacity_index BETWEEN 0 AND 1),
    recovery_capacity_index REAL NOT NULL CHECK (recovery_capacity_index BETWEEN 0 AND 1),
    equity_vulnerability_index REAL NOT NULL CHECK (equity_vulnerability_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

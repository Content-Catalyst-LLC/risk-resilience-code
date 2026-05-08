-- Public Institution Stress Test Panel Schema
-- Article: Stress Testing Public Institutions

CREATE TABLE IF NOT EXISTS public_institution_stress_test_panel (
    institution_id INTEGER PRIMARY KEY,
    institution_or_system TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    public_function TEXT NOT NULL,

    essential_function_clarity_index REAL NOT NULL CHECK (essential_function_clarity_index BETWEEN 0 AND 1),
    capacity_margin_index REAL NOT NULL CHECK (capacity_margin_index BETWEEN 0 AND 1),
    dependency_visibility_index REAL NOT NULL CHECK (dependency_visibility_index BETWEEN 0 AND 1),
    workforce_resilience_index REAL NOT NULL CHECK (workforce_resilience_index BETWEEN 0 AND 1),
    digital_resilience_index REAL NOT NULL CHECK (digital_resilience_index BETWEEN 0 AND 1),
    legal_authority_clarity_index REAL NOT NULL CHECK (legal_authority_clarity_index BETWEEN 0 AND 1),
    coordination_capacity_index REAL NOT NULL CHECK (coordination_capacity_index BETWEEN 0 AND 1),
    equity_protection_index REAL NOT NULL CHECK (equity_protection_index BETWEEN 0 AND 1),
    public_trust_index REAL NOT NULL CHECK (public_trust_index BETWEEN 0 AND 1),
    recovery_capacity_index REAL NOT NULL CHECK (recovery_capacity_index BETWEEN 0 AND 1),
    backup_systems_index REAL NOT NULL CHECK (backup_systems_index BETWEEN 0 AND 1),
    mutual_aid_capacity_index REAL NOT NULL CHECK (mutual_aid_capacity_index BETWEEN 0 AND 1),
    fiscal_reserve_capacity_index REAL NOT NULL CHECK (fiscal_reserve_capacity_index BETWEEN 0 AND 1),
    learning_capacity_index REAL NOT NULL CHECK (learning_capacity_index BETWEEN 0 AND 1),
    accountability_mechanism_index REAL NOT NULL CHECK (accountability_mechanism_index BETWEEN 0 AND 1),
    overload_pressure_index REAL NOT NULL CHECK (overload_pressure_index BETWEEN 0 AND 1),
    institutional_fragmentation_index REAL NOT NULL CHECK (institutional_fragmentation_index BETWEEN 0 AND 1),
    hidden_fragility_index REAL NOT NULL CHECK (hidden_fragility_index BETWEEN 0 AND 1),
    vendor_dependency_index REAL NOT NULL CHECK (vendor_dependency_index BETWEEN 0 AND 1),
    compound_stress_exposure_index REAL NOT NULL CHECK (compound_stress_exposure_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS public_institution_stress_test_view AS
SELECT
    institution_id,
    institution_or_system,
    jurisdiction,
    public_function,

    (
        0.10 * essential_function_clarity_index +
        0.10 * capacity_margin_index +
        0.09 * dependency_visibility_index +
        0.09 * workforce_resilience_index +
        0.09 * digital_resilience_index +
        0.08 * legal_authority_clarity_index +
        0.09 * coordination_capacity_index +
        0.09 * equity_protection_index +
        0.08 * public_trust_index +
        0.07 * recovery_capacity_index +
        0.06 * learning_capacity_index +
        0.06 * accountability_mechanism_index
    ) AS stress_readiness_score,

    (
        0.15 * overload_pressure_index +
        0.14 * institutional_fragmentation_index +
        0.14 * hidden_fragility_index +
        0.13 * vendor_dependency_index +
        0.13 * compound_stress_exposure_index +
        0.09 * (1 - capacity_margin_index) +
        0.08 * (1 - dependency_visibility_index) +
        0.07 * (1 - digital_resilience_index) +
        0.07 * (1 - workforce_resilience_index) +
        0.06 * (1 - public_trust_index)
    ) AS stress_vulnerability_score,

    (
        0.18 * recovery_capacity_index +
        0.16 * backup_systems_index +
        0.15 * mutual_aid_capacity_index +
        0.15 * fiscal_reserve_capacity_index +
        0.14 * learning_capacity_index +
        0.12 * accountability_mechanism_index +
        0.10 * coordination_capacity_index
    ) AS institutional_recovery_score

FROM public_institution_stress_test_panel;

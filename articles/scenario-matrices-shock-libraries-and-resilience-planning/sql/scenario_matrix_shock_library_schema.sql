-- Scenario Matrices, Shock Libraries, and Resilience Planning Schema
-- Article: Scenario Matrices, Shock Libraries, and Resilience Planning

CREATE TABLE IF NOT EXISTS scenario_matrix_shock_library_panel (
    planning_id INTEGER PRIMARY KEY,
    planning_system TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    system_type TEXT NOT NULL,

    scenario_coverage_index REAL NOT NULL CHECK (scenario_coverage_index BETWEEN 0 AND 1),
    shock_library_quality_index REAL NOT NULL CHECK (shock_library_quality_index BETWEEN 0 AND 1),
    shock_specificity_index REAL NOT NULL CHECK (shock_specificity_index BETWEEN 0 AND 1),
    compound_risk_coverage_index REAL NOT NULL CHECK (compound_risk_coverage_index BETWEEN 0 AND 1),
    essential_function_mapping_index REAL NOT NULL CHECK (essential_function_mapping_index BETWEEN 0 AND 1),
    dependency_mapping_index REAL NOT NULL CHECK (dependency_mapping_index BETWEEN 0 AND 1),
    trigger_readiness_index REAL NOT NULL CHECK (trigger_readiness_index BETWEEN 0 AND 1),
    threshold_clarity_index REAL NOT NULL CHECK (threshold_clarity_index BETWEEN 0 AND 1),
    equity_integration_index REAL NOT NULL CHECK (equity_integration_index BETWEEN 0 AND 1),
    community_validation_index REAL NOT NULL CHECK (community_validation_index BETWEEN 0 AND 1),
    stress_test_linkage_index REAL NOT NULL CHECK (stress_test_linkage_index BETWEEN 0 AND 1),
    governance_ownership_index REAL NOT NULL CHECK (governance_ownership_index BETWEEN 0 AND 1),
    update_cadence_index REAL NOT NULL CHECK (update_cadence_index BETWEEN 0 AND 1),
    action_linkage_index REAL NOT NULL CHECK (action_linkage_index BETWEEN 0 AND 1),
    adaptive_decision_capacity_index REAL NOT NULL CHECK (adaptive_decision_capacity_index BETWEEN 0 AND 1),
    compound_risk_exposure_index REAL NOT NULL CHECK (compound_risk_exposure_index BETWEEN 0 AND 1),
    blind_spot_gap_index REAL NOT NULL CHECK (blind_spot_gap_index BETWEEN 0 AND 1),
    stale_assumption_risk_index REAL NOT NULL CHECK (stale_assumption_risk_index BETWEEN 0 AND 1),
    scenario_theater_risk_index REAL NOT NULL CHECK (scenario_theater_risk_index BETWEEN 0 AND 1),
    untested_fragility_index REAL NOT NULL CHECK (untested_fragility_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS scenario_matrix_shock_library_view AS
SELECT
    planning_id,
    planning_system,
    jurisdiction,
    system_type,

    (
        0.16 * scenario_coverage_index +
        0.13 * compound_risk_coverage_index +
        0.13 * essential_function_mapping_index +
        0.12 * dependency_mapping_index +
        0.12 * trigger_readiness_index +
        0.11 * threshold_clarity_index +
        0.11 * equity_integration_index +
        0.12 * stress_test_linkage_index
    ) AS scenario_matrix_quality_score,

    (
        0.18 * shock_library_quality_index +
        0.16 * shock_specificity_index +
        0.14 * compound_risk_coverage_index +
        0.13 * dependency_mapping_index +
        0.12 * essential_function_mapping_index +
        0.10 * community_validation_index +
        0.09 * update_cadence_index +
        0.08 * governance_ownership_index
    ) AS shock_library_reliability_score,

    (
        0.20 * action_linkage_index +
        0.18 * governance_ownership_index +
        0.16 * trigger_readiness_index +
        0.14 * threshold_clarity_index +
        0.12 * stress_test_linkage_index +
        0.10 * adaptive_decision_capacity_index +
        0.10 * update_cadence_index
    ) AS planning_actionability_score,

    (
        0.22 * compound_risk_exposure_index +
        0.20 * blind_spot_gap_index +
        0.18 * stale_assumption_risk_index +
        0.16 * scenario_theater_risk_index +
        0.14 * untested_fragility_index +
        0.10 * (1 - community_validation_index)
    ) AS blind_spot_pressure_score

FROM scenario_matrix_shock_library_panel;

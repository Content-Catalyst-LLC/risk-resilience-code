-- The Future of Resilience Thinking Schema
-- Article: The Future of Resilience Thinking

CREATE TABLE IF NOT EXISTS future_resilience_framework_panel (
    strategy_id INTEGER PRIMARY KEY,
    strategy_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    strategy_domain TEXT NOT NULL,

    systemic_risk_capacity_index REAL NOT NULL CHECK (systemic_risk_capacity_index BETWEEN 0 AND 1),
    governance_integration_index REAL NOT NULL CHECK (governance_integration_index BETWEEN 0 AND 1),
    justice_transformation_index REAL NOT NULL CHECK (justice_transformation_index BETWEEN 0 AND 1),
    regenerative_capacity_index REAL NOT NULL CHECK (regenerative_capacity_index BETWEEN 0 AND 1),
    local_capability_index REAL NOT NULL CHECK (local_capability_index BETWEEN 0 AND 1),
    technological_accountability_index REAL NOT NULL CHECK (technological_accountability_index BETWEEN 0 AND 1),
    planetary_alignment_index REAL NOT NULL CHECK (planetary_alignment_index BETWEEN 0 AND 1),
    investment_readiness_index REAL NOT NULL CHECK (investment_readiness_index BETWEEN 0 AND 1),
    data_accountability_index REAL NOT NULL CHECK (data_accountability_index BETWEEN 0 AND 1),
    learning_capacity_index REAL NOT NULL CHECK (learning_capacity_index BETWEEN 0 AND 1),

    fragmentation_risk_index REAL NOT NULL CHECK (fragmentation_risk_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),
    inequality_risk_index REAL NOT NULL CHECK (inequality_risk_index BETWEEN 0 AND 1),
    ecological_overshoot_risk_index REAL NOT NULL CHECK (ecological_overshoot_risk_index BETWEEN 0 AND 1),
    technological_dependency_risk_index REAL NOT NULL CHECK (technological_dependency_risk_index BETWEEN 0 AND 1),
    conceptual_vagueness_index REAL NOT NULL CHECK (conceptual_vagueness_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    responsible_institution TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS future_resilience_review_events (
    review_event_id INTEGER PRIMARY KEY,
    strategy_name TEXT NOT NULL,
    review_date TEXT NOT NULL,
    review_type TEXT NOT NULL,
    review_finding TEXT,
    affected_domain TEXT,
    corrective_action TEXT,
    accountability_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS future_resilience_framework_view AS
SELECT
    strategy_id,
    strategy_name,
    jurisdiction,
    strategy_domain,

    (
        0.14 * systemic_risk_capacity_index +
        0.13 * governance_integration_index +
        0.12 * justice_transformation_index +
        0.12 * regenerative_capacity_index +
        0.10 * local_capability_index +
        0.10 * technological_accountability_index +
        0.10 * planetary_alignment_index +
        0.08 * investment_readiness_index +
        0.06 * data_accountability_index +
        0.05 * learning_capacity_index
    ) AS future_resilience_capacity_score,

    (
        0.18 * fragmentation_risk_index +
        0.18 * maladaptation_risk_index +
        0.17 * inequality_risk_index +
        0.17 * ecological_overshoot_risk_index +
        0.15 * technological_dependency_risk_index +
        0.15 * conceptual_vagueness_index
    ) AS future_fragility_pressure_score,

    (
        0.30 * (1 - conceptual_vagueness_index) +
        0.25 * data_accountability_index +
        0.25 * learning_capacity_index +
        0.20 * governance_integration_index
    ) AS conceptual_discipline_score

FROM future_resilience_framework_panel;

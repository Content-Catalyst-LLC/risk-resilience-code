-- Polycrisis, Systemic Risk, and the Future of Resilience Thinking Schema
-- Article: Polycrisis, Systemic Risk, and the Future of Resilience Thinking

CREATE TABLE IF NOT EXISTS polycrisis_domain_panel (
    domain_id INTEGER PRIMARY KEY,
    domain TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,

    crisis_intensity_index REAL NOT NULL CHECK (crisis_intensity_index BETWEEN 0 AND 1),
    systemic_vulnerability_index REAL NOT NULL CHECK (systemic_vulnerability_index BETWEEN 0 AND 1),
    feedback_amplification_index REAL NOT NULL CHECK (feedback_amplification_index BETWEEN 0 AND 1),
    threshold_proximity_index REAL NOT NULL CHECK (threshold_proximity_index BETWEEN 0 AND 1),
    institutional_capacity_index REAL NOT NULL CHECK (institutional_capacity_index BETWEEN 0 AND 1),
    public_legitimacy_index REAL NOT NULL CHECK (public_legitimacy_index BETWEEN 0 AND 1),
    regenerative_capacity_index REAL NOT NULL CHECK (regenerative_capacity_index BETWEEN 0 AND 1),
    equity_integration_index REAL NOT NULL CHECK (equity_integration_index BETWEEN 0 AND 1),
    data_auditability_index REAL NOT NULL CHECK (data_auditability_index BETWEEN 0 AND 1),
    adaptive_learning_index REAL NOT NULL CHECK (adaptive_learning_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS polycrisis_interaction_matrix (
    interaction_id INTEGER PRIMARY KEY,
    source_domain TEXT NOT NULL,
    target_domain TEXT NOT NULL,
    coupling_weight REAL NOT NULL CHECK (coupling_weight BETWEEN 0 AND 1),
    interaction_type TEXT,
    pathway_description TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS polycrisis_domain_scores_view AS
SELECT
    domain_id,
    domain,
    jurisdiction,

    (
        0.22 * crisis_intensity_index +
        0.20 * systemic_vulnerability_index +
        0.18 * feedback_amplification_index +
        0.17 * threshold_proximity_index +
        0.13 * maladaptation_risk_index +
        0.10 * (1 - institutional_capacity_index)
    ) AS domain_polycrisis_pressure_score,

    (
        0.18 * institutional_capacity_index +
        0.16 * public_legitimacy_index +
        0.16 * regenerative_capacity_index +
        0.14 * equity_integration_index +
        0.12 * data_auditability_index +
        0.12 * adaptive_learning_index +
        0.12 * (1 - maladaptation_risk_index)
    ) AS transformative_resilience_score

FROM polycrisis_domain_panel;

CREATE VIEW IF NOT EXISTS polycrisis_interaction_scores_view AS
SELECT
    i.interaction_id,
    i.source_domain,
    i.target_domain,
    i.coupling_weight,
    i.interaction_type,
    i.pathway_description,

    s.domain_polycrisis_pressure_score AS source_pressure,
    t.domain_polycrisis_pressure_score AS target_pressure,

    (
        s.domain_polycrisis_pressure_score *
        t.domain_polycrisis_pressure_score *
        i.coupling_weight
    ) AS interaction_pressure_score

FROM polycrisis_interaction_matrix i
JOIN polycrisis_domain_scores_view s
    ON i.source_domain = s.domain
JOIN polycrisis_domain_scores_view t
    ON i.target_domain = t.domain;

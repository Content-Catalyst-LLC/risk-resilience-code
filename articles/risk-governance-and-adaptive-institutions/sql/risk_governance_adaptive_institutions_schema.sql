-- Risk Governance and Adaptive Institutions Panel Schema
-- Article: Risk Governance and Adaptive Institutions

CREATE TABLE IF NOT EXISTS risk_governance_institutions_panel (
    institution_id INTEGER PRIMARY KEY,
    institution_or_system TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    risk_domain TEXT NOT NULL,

    anticipatory_capacity_index REAL NOT NULL CHECK (anticipatory_capacity_index BETWEEN 0 AND 1),
    appraisal_quality_index REAL NOT NULL CHECK (appraisal_quality_index BETWEEN 0 AND 1),
    coordination_capacity_index REAL NOT NULL CHECK (coordination_capacity_index BETWEEN 0 AND 1),
    participation_strength_index REAL NOT NULL CHECK (participation_strength_index BETWEEN 0 AND 1),
    transparency_index REAL NOT NULL CHECK (transparency_index BETWEEN 0 AND 1),
    legitimacy_index REAL NOT NULL CHECK (legitimacy_index BETWEEN 0 AND 1),
    learning_capacity_index REAL NOT NULL CHECK (learning_capacity_index BETWEEN 0 AND 1),
    institutional_memory_index REAL NOT NULL CHECK (institutional_memory_index BETWEEN 0 AND 1),
    justice_orientation_index REAL NOT NULL CHECK (justice_orientation_index BETWEEN 0 AND 1),
    monitoring_feedback_index REAL NOT NULL CHECK (monitoring_feedback_index BETWEEN 0 AND 1),
    policy_revision_capacity_index REAL NOT NULL CHECK (policy_revision_capacity_index BETWEEN 0 AND 1),
    fragmentation_index REAL NOT NULL CHECK (fragmentation_index BETWEEN 0 AND 1),
    uncertainty_load_index REAL NOT NULL CHECK (uncertainty_load_index BETWEEN 0 AND 1),
    capture_risk_index REAL NOT NULL CHECK (capture_risk_index BETWEEN 0 AND 1),
    systemic_risk_exposure_index REAL NOT NULL CHECK (systemic_risk_exposure_index BETWEEN 0 AND 1),
    vulnerability_exposure_index REAL NOT NULL CHECK (vulnerability_exposure_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS risk_governance_adaptive_institutions_view AS
SELECT
    institution_id,
    institution_or_system,
    jurisdiction,
    risk_domain,

    (
        0.11 * anticipatory_capacity_index +
        0.11 * appraisal_quality_index +
        0.11 * coordination_capacity_index +
        0.10 * participation_strength_index +
        0.09 * transparency_index +
        0.10 * legitimacy_index +
        0.10 * learning_capacity_index +
        0.08 * institutional_memory_index +
        0.08 * justice_orientation_index +
        0.07 * monitoring_feedback_index +
        0.05 * policy_revision_capacity_index
    ) AS risk_governance_quality_score,

    (
        0.16 * monitoring_feedback_index +
        0.15 * policy_revision_capacity_index +
        0.15 * coordination_capacity_index +
        0.14 * learning_capacity_index +
        0.12 * institutional_memory_index +
        0.11 * participation_strength_index +
        0.09 * legitimacy_index +
        0.08 * justice_orientation_index
    ) AS adaptive_institutional_capacity_score,

    (
        0.18 * fragmentation_index +
        0.16 * uncertainty_load_index +
        0.15 * capture_risk_index +
        0.14 * systemic_risk_exposure_index +
        0.12 * vulnerability_exposure_index +
        0.09 * (1 - coordination_capacity_index) +
        0.08 * (1 - transparency_index) +
        0.08 * (1 - learning_capacity_index)
    ) AS governance_vulnerability_score

FROM risk_governance_institutions_panel;

-- Resilience Governance, Accountability, and Public Legitimacy Panel Schema
-- Article: Resilience Governance, Accountability, and Public Legitimacy

CREATE TABLE IF NOT EXISTS resilience_governance_legitimacy_panel (
    institution_id INTEGER PRIMARY KEY,
    institution_or_system TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    risk_domain TEXT NOT NULL,

    adaptive_capacity_index REAL NOT NULL CHECK (adaptive_capacity_index BETWEEN 0 AND 1),
    accountability_capacity_index REAL NOT NULL CHECK (accountability_capacity_index BETWEEN 0 AND 1),
    public_legitimacy_index REAL NOT NULL CHECK (public_legitimacy_index BETWEEN 0 AND 1),
    transparency_index REAL NOT NULL CHECK (transparency_index BETWEEN 0 AND 1),
    participation_strength_index REAL NOT NULL CHECK (participation_strength_index BETWEEN 0 AND 1),
    coordination_capacity_index REAL NOT NULL CHECK (coordination_capacity_index BETWEEN 0 AND 1),
    learning_capacity_index REAL NOT NULL CHECK (learning_capacity_index BETWEEN 0 AND 1),
    institutional_memory_index REAL NOT NULL CHECK (institutional_memory_index BETWEEN 0 AND 1),
    justice_orientation_index REAL NOT NULL CHECK (justice_orientation_index BETWEEN 0 AND 1),
    oversight_strength_index REAL NOT NULL CHECK (oversight_strength_index BETWEEN 0 AND 1),
    remedy_availability_index REAL NOT NULL CHECK (remedy_availability_index BETWEEN 0 AND 1),
    correction_capacity_index REAL NOT NULL CHECK (correction_capacity_index BETWEEN 0 AND 1),
    fragmentation_index REAL NOT NULL CHECK (fragmentation_index BETWEEN 0 AND 1),
    capture_risk_index REAL NOT NULL CHECK (capture_risk_index BETWEEN 0 AND 1),
    trust_erosion_index REAL NOT NULL CHECK (trust_erosion_index BETWEEN 0 AND 1),
    vulnerability_exposure_index REAL NOT NULL CHECK (vulnerability_exposure_index BETWEEN 0 AND 1),
    systemic_risk_exposure_index REAL NOT NULL CHECK (systemic_risk_exposure_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS resilience_governance_legitimacy_view AS
SELECT
    institution_id,
    institution_or_system,
    jurisdiction,
    risk_domain,

    (
        0.11 * adaptive_capacity_index +
        0.11 * accountability_capacity_index +
        0.10 * public_legitimacy_index +
        0.09 * transparency_index +
        0.09 * participation_strength_index +
        0.09 * coordination_capacity_index +
        0.09 * learning_capacity_index +
        0.08 * institutional_memory_index +
        0.08 * justice_orientation_index +
        0.08 * oversight_strength_index +
        0.08 * correction_capacity_index
    ) AS resilience_governance_quality_score,

    (
        0.16 * accountability_capacity_index +
        0.14 * public_legitimacy_index +
        0.13 * transparency_index +
        0.12 * oversight_strength_index +
        0.12 * remedy_availability_index +
        0.12 * correction_capacity_index +
        0.11 * participation_strength_index +
        0.10 * justice_orientation_index
    ) AS accountability_legitimacy_capacity_score,

    (
        0.17 * fragmentation_index +
        0.16 * capture_risk_index +
        0.15 * trust_erosion_index +
        0.14 * vulnerability_exposure_index +
        0.13 * systemic_risk_exposure_index +
        0.09 * (1 - accountability_capacity_index) +
        0.08 * (1 - transparency_index) +
        0.08 * (1 - learning_capacity_index)
    ) AS governance_vulnerability_score

FROM resilience_governance_legitimacy_panel;

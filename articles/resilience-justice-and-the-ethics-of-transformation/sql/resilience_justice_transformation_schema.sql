-- Resilience, Justice, and the Ethics of Transformation Schema
-- Article: Resilience, Justice, and the Ethics of Transformation

CREATE TABLE IF NOT EXISTS resilience_justice_transformation_panel (
    initiative_id INTEGER PRIMARY KEY,
    initiative_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    transformation_domain TEXT NOT NULL,

    technical_resilience_index REAL NOT NULL CHECK (technical_resilience_index BETWEEN 0 AND 1),
    distributive_justice_index REAL NOT NULL CHECK (distributive_justice_index BETWEEN 0 AND 1),
    procedural_justice_index REAL NOT NULL CHECK (procedural_justice_index BETWEEN 0 AND 1),
    recognition_index REAL NOT NULL CHECK (recognition_index BETWEEN 0 AND 1),
    rights_protection_index REAL NOT NULL CHECK (rights_protection_index BETWEEN 0 AND 1),
    institutional_accountability_index REAL NOT NULL CHECK (institutional_accountability_index BETWEEN 0 AND 1),
    ecological_governance_index REAL NOT NULL CHECK (ecological_governance_index BETWEEN 0 AND 1),
    intergenerational_responsibility_index REAL NOT NULL CHECK (intergenerational_responsibility_index BETWEEN 0 AND 1),
    public_legitimacy_index REAL NOT NULL CHECK (public_legitimacy_index BETWEEN 0 AND 1),
    data_transparency_index REAL NOT NULL CHECK (data_transparency_index BETWEEN 0 AND 1),

    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),
    harm_shifting_risk_index REAL NOT NULL CHECK (harm_shifting_risk_index BETWEEN 0 AND 1),
    exclusion_risk_index REAL NOT NULL CHECK (exclusion_risk_index BETWEEN 0 AND 1),
    coercion_risk_index REAL NOT NULL CHECK (coercion_risk_index BETWEEN 0 AND 1),
    displacement_risk_index REAL NOT NULL CHECK (displacement_risk_index BETWEEN 0 AND 1),
    unequal_burden_index REAL NOT NULL CHECK (unequal_burden_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    responsible_institution TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS justice_transformation_accountability_events (
    accountability_event_id INTEGER PRIMARY KEY,
    initiative_name TEXT NOT NULL,
    event_date TEXT NOT NULL,
    event_type TEXT NOT NULL,
    affected_group TEXT,
    issue_description TEXT,
    institutional_response TEXT,
    remedy_status TEXT,
    public_reporting_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS resilience_justice_transformation_view AS
SELECT
    initiative_id,
    initiative_name,
    jurisdiction,
    transformation_domain,

    (
        0.16 * distributive_justice_index +
        0.15 * procedural_justice_index +
        0.13 * recognition_index +
        0.13 * rights_protection_index +
        0.12 * institutional_accountability_index +
        0.10 * ecological_governance_index +
        0.09 * intergenerational_responsibility_index +
        0.07 * public_legitimacy_index +
        0.05 * data_transparency_index
    ) AS justice_oriented_transformation_score,

    (
        0.20 * maladaptation_risk_index +
        0.18 * harm_shifting_risk_index +
        0.17 * exclusion_risk_index +
        0.15 * coercion_risk_index +
        0.15 * displacement_risk_index +
        0.15 * unequal_burden_index
    ) AS ethical_risk_pressure_score,

    (
        technical_resilience_index -
        (
            0.16 * distributive_justice_index +
            0.15 * procedural_justice_index +
            0.13 * recognition_index +
            0.13 * rights_protection_index +
            0.12 * institutional_accountability_index +
            0.10 * ecological_governance_index +
            0.09 * intergenerational_responsibility_index +
            0.07 * public_legitimacy_index +
            0.05 * data_transparency_index
        )
    ) AS technical_justice_gap

FROM resilience_justice_transformation_panel;

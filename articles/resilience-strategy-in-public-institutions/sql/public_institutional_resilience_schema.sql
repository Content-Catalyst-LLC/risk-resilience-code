-- Public Institutional Resilience Strategy Schema
-- Article URL slug: resilience-strategy-in-public-institutions

CREATE TABLE IF NOT EXISTS public_institutional_resilience_panel (
    institution_id INTEGER PRIMARY KEY,
    institution_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    institution_type TEXT NOT NULL,
    primary_service_domain TEXT NOT NULL,

    anticipatory_foresight_index REAL NOT NULL CHECK (anticipatory_foresight_index BETWEEN 0 AND 1),
    continuity_operations_index REAL NOT NULL CHECK (continuity_operations_index BETWEEN 0 AND 1),
    administrative_capacity_index REAL NOT NULL CHECK (administrative_capacity_index BETWEEN 0 AND 1),
    coordination_capacity_index REAL NOT NULL CHECK (coordination_capacity_index BETWEEN 0 AND 1),
    risk_informed_finance_index REAL NOT NULL CHECK (risk_informed_finance_index BETWEEN 0 AND 1),
    procurement_resilience_index REAL NOT NULL CHECK (procurement_resilience_index BETWEEN 0 AND 1),
    digital_fallback_index REAL NOT NULL CHECK (digital_fallback_index BETWEEN 0 AND 1),
    public_legitimacy_index REAL NOT NULL CHECK (public_legitimacy_index BETWEEN 0 AND 1),
    justice_service_equity_index REAL NOT NULL CHECK (justice_service_equity_index BETWEEN 0 AND 1),
    learning_adaptation_index REAL NOT NULL CHECK (learning_adaptation_index BETWEEN 0 AND 1),

    fragmentation_risk_index REAL NOT NULL CHECK (fragmentation_risk_index BETWEEN 0 AND 1),
    underinvestment_risk_index REAL NOT NULL CHECK (underinvestment_risk_index BETWEEN 0 AND 1),
    staffing_fragility_index REAL NOT NULL CHECK (staffing_fragility_index BETWEEN 0 AND 1),
    digital_dependency_risk_index REAL NOT NULL CHECK (digital_dependency_risk_index BETWEEN 0 AND 1),
    procurement_vulnerability_index REAL NOT NULL CHECK (procurement_vulnerability_index BETWEEN 0 AND 1),
    accountability_gap_index REAL NOT NULL CHECK (accountability_gap_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    lead_public_body TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS institutional_resilience_review_events (
    review_event_id INTEGER PRIMARY KEY,
    institution_name TEXT NOT NULL,
    review_date TEXT NOT NULL,
    review_type TEXT NOT NULL,
    stress_event_or_scenario TEXT,
    finding TEXT,
    corrective_action TEXT,
    accountability_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS public_institutional_resilience_view AS
SELECT
    institution_id,
    institution_name,
    jurisdiction,
    institution_type,
    primary_service_domain,

    (
        0.13 * anticipatory_foresight_index +
        0.13 * continuity_operations_index +
        0.12 * administrative_capacity_index +
        0.11 * coordination_capacity_index +
        0.10 * risk_informed_finance_index +
        0.10 * procurement_resilience_index +
        0.08 * digital_fallback_index +
        0.08 * public_legitimacy_index +
        0.08 * justice_service_equity_index +
        0.07 * learning_adaptation_index
    ) AS institutional_resilience_capacity_score,

    (
        0.18 * fragmentation_risk_index +
        0.18 * underinvestment_risk_index +
        0.17 * staffing_fragility_index +
        0.16 * digital_dependency_risk_index +
        0.15 * procurement_vulnerability_index +
        0.16 * accountability_gap_index
    ) AS institutional_fragility_pressure_score,

    (
        0.50 *
        (
            0.13 * anticipatory_foresight_index +
            0.13 * continuity_operations_index +
            0.12 * administrative_capacity_index +
            0.11 * coordination_capacity_index +
            0.10 * risk_informed_finance_index +
            0.10 * procurement_resilience_index +
            0.08 * digital_fallback_index +
            0.08 * public_legitimacy_index +
            0.08 * justice_service_equity_index +
            0.07 * learning_adaptation_index
        )
        + 0.20 * public_legitimacy_index
        + 0.15 * justice_service_equity_index
        + 0.15 * (1 - accountability_gap_index)
    ) AS legitimacy_adjusted_resilience_score

FROM public_institutional_resilience_panel;

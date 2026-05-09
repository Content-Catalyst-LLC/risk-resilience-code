-- Cross-Sector Coordination and Integrated Resilience Governance Schema
-- Article: Cross-Sector Coordination and Integrated Resilience Governance

CREATE TABLE IF NOT EXISTS integrated_resilience_governance_panel (
    governance_id INTEGER PRIMARY KEY,
    jurisdiction TEXT NOT NULL,
    governance_system TEXT NOT NULL,
    primary_risk_domain TEXT NOT NULL,

    cross_sector_coordination_index REAL NOT NULL CHECK (cross_sector_coordination_index BETWEEN 0 AND 1),
    dependency_visibility_index REAL NOT NULL CHECK (dependency_visibility_index BETWEEN 0 AND 1),
    governance_integration_index REAL NOT NULL CHECK (governance_integration_index BETWEEN 0 AND 1),
    data_interoperability_index REAL NOT NULL CHECK (data_interoperability_index BETWEEN 0 AND 1),
    public_accountability_index REAL NOT NULL CHECK (public_accountability_index BETWEEN 0 AND 1),
    justice_equity_index REAL NOT NULL CHECK (justice_equity_index BETWEEN 0 AND 1),
    local_capability_index REAL NOT NULL CHECK (local_capability_index BETWEEN 0 AND 1),
    adaptive_learning_index REAL NOT NULL CHECK (adaptive_learning_index BETWEEN 0 AND 1),
    investment_alignment_index REAL NOT NULL CHECK (investment_alignment_index BETWEEN 0 AND 1),

    fragmentation_risk_index REAL NOT NULL CHECK (fragmentation_risk_index BETWEEN 0 AND 1),
    mandate_conflict_index REAL NOT NULL CHECK (mandate_conflict_index BETWEEN 0 AND 1),
    governance_data_gap_index REAL NOT NULL CHECK (governance_data_gap_index BETWEEN 0 AND 1),
    maladaptation_risk_index REAL NOT NULL CHECK (maladaptation_risk_index BETWEEN 0 AND 1),
    private_operator_opacity_index REAL NOT NULL CHECK (private_operator_opacity_index BETWEEN 0 AND 1),
    accountability_diffusion_index REAL NOT NULL CHECK (accountability_diffusion_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    lead_institution TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS cross_sector_coordination_events (
    coordination_event_id INTEGER PRIMARY KEY,
    jurisdiction TEXT NOT NULL,
    event_date TEXT NOT NULL,
    event_type TEXT NOT NULL,
    sectors_involved TEXT,
    coordination_issue TEXT,
    corrective_action TEXT,
    accountability_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS integrated_resilience_governance_view AS
SELECT
    governance_id,
    jurisdiction,
    governance_system,
    primary_risk_domain,

    (
        0.16 * cross_sector_coordination_index +
        0.14 * dependency_visibility_index +
        0.13 * governance_integration_index +
        0.11 * data_interoperability_index +
        0.11 * public_accountability_index +
        0.10 * justice_equity_index +
        0.09 * local_capability_index +
        0.08 * adaptive_learning_index +
        0.08 * investment_alignment_index
    ) AS integrated_governance_capacity_score,

    (
        0.19 * fragmentation_risk_index +
        0.17 * mandate_conflict_index +
        0.17 * governance_data_gap_index +
        0.16 * maladaptation_risk_index +
        0.15 * private_operator_opacity_index +
        0.16 * accountability_diffusion_index
    ) AS coordination_fragility_pressure_score,

    (
        (
            0.16 * cross_sector_coordination_index +
            0.14 * dependency_visibility_index +
            0.13 * governance_integration_index +
            0.11 * data_interoperability_index +
            0.11 * public_accountability_index +
            0.10 * justice_equity_index +
            0.09 * local_capability_index +
            0.08 * adaptive_learning_index +
            0.08 * investment_alignment_index
        )
        -
        (
            0.19 * fragmentation_risk_index +
            0.17 * mandate_conflict_index +
            0.17 * governance_data_gap_index +
            0.16 * maladaptation_risk_index +
            0.15 * private_operator_opacity_index +
            0.16 * accountability_diffusion_index
        )
    ) AS integrated_resilience_governance_gap

FROM integrated_resilience_governance_panel;

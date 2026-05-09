-- Resilience Data, Provenance, and Auditability Schema
-- Article: Resilience Data, Provenance, and Auditability

CREATE TABLE IF NOT EXISTS resilience_data_provenance_panel (
    dataset_id INTEGER PRIMARY KEY,
    dataset_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    data_domain TEXT NOT NULL,

    provenance_completeness_index REAL NOT NULL CHECK (provenance_completeness_index BETWEEN 0 AND 1),
    metadata_quality_index REAL NOT NULL CHECK (metadata_quality_index BETWEEN 0 AND 1),
    lineage_clarity_index REAL NOT NULL CHECK (lineage_clarity_index BETWEEN 0 AND 1),
    audit_evidence_index REAL NOT NULL CHECK (audit_evidence_index BETWEEN 0 AND 1),
    reproducibility_index REAL NOT NULL CHECK (reproducibility_index BETWEEN 0 AND 1),
    data_quality_index REAL NOT NULL CHECK (data_quality_index BETWEEN 0 AND 1),
    version_control_index REAL NOT NULL CHECK (version_control_index BETWEEN 0 AND 1),
    chain_of_custody_index REAL NOT NULL CHECK (chain_of_custody_index BETWEEN 0 AND 1),
    equity_coverage_index REAL NOT NULL CHECK (equity_coverage_index BETWEEN 0 AND 1),
    community_validation_index REAL NOT NULL CHECK (community_validation_index BETWEEN 0 AND 1),
    privacy_safeguard_index REAL NOT NULL CHECK (privacy_safeguard_index BETWEEN 0 AND 1),
    security_control_index REAL NOT NULL CHECK (security_control_index BETWEEN 0 AND 1),
    responsible_owner_index REAL NOT NULL CHECK (responsible_owner_index BETWEEN 0 AND 1),
    missingness_gap_index REAL NOT NULL CHECK (missingness_gap_index BETWEEN 0 AND 1),
    opacity_risk_index REAL NOT NULL CHECK (opacity_risk_index BETWEEN 0 AND 1),
    undocumented_transformation_index REAL NOT NULL CHECK (undocumented_transformation_index BETWEEN 0 AND 1),
    stale_data_risk_index REAL NOT NULL CHECK (stale_data_risk_index BETWEEN 0 AND 1),
    sensitive_data_exposure_risk_index REAL NOT NULL CHECK (sensitive_data_exposure_risk_index BETWEEN 0 AND 1),
    audit_gap_index REAL NOT NULL CHECK (audit_gap_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    data_owner TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS resilience_data_lineage_events (
    lineage_event_id INTEGER PRIMARY KEY,
    dataset_name TEXT NOT NULL,
    event_timestamp TEXT NOT NULL,
    event_type TEXT NOT NULL,
    actor TEXT,
    source_artifact TEXT,
    target_artifact TEXT,
    transformation_description TEXT,
    code_version TEXT,
    data_version TEXT,
    approval_status TEXT,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS resilience_data_provenance_view AS
SELECT
    dataset_id,
    dataset_name,
    jurisdiction,
    data_domain,

    (
        0.22 * provenance_completeness_index +
        0.18 * metadata_quality_index +
        0.18 * lineage_clarity_index +
        0.14 * version_control_index +
        0.12 * responsible_owner_index +
        0.10 * data_quality_index +
        0.06 * chain_of_custody_index
    ) AS provenance_strength_score,

    (
        0.24 * audit_evidence_index +
        0.18 * reproducibility_index +
        0.16 * version_control_index +
        0.14 * chain_of_custody_index +
        0.12 * responsible_owner_index +
        0.10 * metadata_quality_index +
        0.06 * lineage_clarity_index
    ) AS auditability_strength_score,

    (
        0.22 * privacy_safeguard_index +
        0.20 * security_control_index +
        0.18 * equity_coverage_index +
        0.16 * community_validation_index +
        0.14 * responsible_owner_index +
        0.10 * data_quality_index
    ) AS ethical_governance_score,

    (
        0.22 * missingness_gap_index +
        0.20 * opacity_risk_index +
        0.18 * undocumented_transformation_index +
        0.15 * stale_data_risk_index +
        0.13 * sensitive_data_exposure_risk_index +
        0.12 * audit_gap_index
    ) AS data_risk_pressure_score

FROM resilience_data_provenance_panel;

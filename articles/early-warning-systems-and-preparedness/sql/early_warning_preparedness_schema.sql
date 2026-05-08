-- Early Warning Systems and Preparedness Panel Schema
-- Article: Early Warning Systems and Preparedness

CREATE TABLE IF NOT EXISTS early_warning_preparedness_panel (
    system_id INTEGER PRIMARY KEY,
    system_name TEXT NOT NULL,
    jurisdiction TEXT NOT NULL,
    hazard_type TEXT NOT NULL,

    risk_knowledge_index REAL NOT NULL CHECK (risk_knowledge_index BETWEEN 0 AND 1),
    forecast_skill_index REAL NOT NULL CHECK (forecast_skill_index BETWEEN 0 AND 1),
    lead_time_index REAL NOT NULL CHECK (lead_time_index BETWEEN 0 AND 1),
    communication_reach_index REAL NOT NULL CHECK (communication_reach_index BETWEEN 0 AND 1),
    trust_strength_index REAL NOT NULL CHECK (trust_strength_index BETWEEN 0 AND 1),
    preparedness_capacity_index REAL NOT NULL CHECK (preparedness_capacity_index BETWEEN 0 AND 1),
    response_capacity_index REAL NOT NULL CHECK (response_capacity_index BETWEEN 0 AND 1),
    protocol_clarity_index REAL NOT NULL CHECK (protocol_clarity_index BETWEEN 0 AND 1),
    equity_access_index REAL NOT NULL CHECK (equity_access_index BETWEEN 0 AND 1),
    household_preparedness_index REAL NOT NULL CHECK (household_preparedness_index BETWEEN 0 AND 1),
    community_preparedness_index REAL NOT NULL CHECK (community_preparedness_index BETWEEN 0 AND 1),
    institutional_preparedness_index REAL NOT NULL CHECK (institutional_preparedness_index BETWEEN 0 AND 1),
    uncertainty_burden_index REAL NOT NULL CHECK (uncertainty_burden_index BETWEEN 0 AND 1),
    access_barrier_index REAL NOT NULL CHECK (access_barrier_index BETWEEN 0 AND 1),
    false_alarm_strain_index REAL NOT NULL CHECK (false_alarm_strain_index BETWEEN 0 AND 1),
    missed_alarm_risk_index REAL NOT NULL CHECK (missed_alarm_risk_index BETWEEN 0 AND 1),
    institutional_fragmentation_index REAL NOT NULL CHECK (institutional_fragmentation_index BETWEEN 0 AND 1),
    vulnerability_exposure_index REAL NOT NULL CHECK (vulnerability_exposure_index BETWEEN 0 AND 1),

    observation_year INTEGER,
    notes TEXT
);

CREATE VIEW IF NOT EXISTS early_warning_preparedness_view AS
SELECT
    system_id,
    system_name,
    jurisdiction,
    hazard_type,

    (
        0.11 * risk_knowledge_index +
        0.11 * forecast_skill_index +
        0.10 * lead_time_index +
        0.10 * communication_reach_index +
        0.09 * trust_strength_index +
        0.10 * preparedness_capacity_index +
        0.10 * response_capacity_index +
        0.08 * protocol_clarity_index +
        0.08 * equity_access_index +
        0.05 * (1 - uncertainty_burden_index) +
        0.04 * (1 - access_barrier_index) +
        0.04 * (1 - institutional_fragmentation_index)
    ) AS warning_effectiveness_score,

    (
        0.17 * household_preparedness_index +
        0.18 * community_preparedness_index +
        0.18 * institutional_preparedness_index +
        0.15 * preparedness_capacity_index +
        0.13 * response_capacity_index +
        0.11 * protocol_clarity_index +
        0.08 * equity_access_index
    ) AS preparedness_system_score,

    (
        0.15 * vulnerability_exposure_index +
        0.14 * access_barrier_index +
        0.13 * institutional_fragmentation_index +
        0.12 * uncertainty_burden_index +
        0.11 * missed_alarm_risk_index +
        0.09 * false_alarm_strain_index +
        0.09 * (1 - trust_strength_index) +
        0.08 * (1 - communication_reach_index) +
        0.05 * (1 - preparedness_capacity_index) +
        0.04 * (1 - response_capacity_index)
    ) AS warning_vulnerability_score

FROM early_warning_preparedness_panel;

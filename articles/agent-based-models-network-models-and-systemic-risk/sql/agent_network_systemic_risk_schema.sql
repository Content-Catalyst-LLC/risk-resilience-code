-- Agent-Based Models, Network Models, and Systemic Risk Schema
-- Article: Agent-Based Models, Network Models, and Systemic Risk

CREATE TABLE IF NOT EXISTS systemic_risk_nodes (
    node_id INTEGER PRIMARY KEY,
    node TEXT NOT NULL UNIQUE,
    system_type TEXT NOT NULL,

    capacity_index REAL NOT NULL CHECK (capacity_index BETWEEN 0 AND 1),
    vulnerability_index REAL NOT NULL CHECK (vulnerability_index BETWEEN 0 AND 1),
    exposure_index REAL NOT NULL CHECK (exposure_index BETWEEN 0 AND 1),
    governance_support_index REAL NOT NULL CHECK (governance_support_index BETWEEN 0 AND 1),
    redundancy_index REAL NOT NULL CHECK (redundancy_index BETWEEN 0 AND 1),
    behavioral_sensitivity_index REAL NOT NULL CHECK (behavioral_sensitivity_index BETWEEN 0 AND 1),
    modularity_support_index REAL CHECK (modularity_support_index BETWEEN 0 AND 1),
    recovery_capacity_index REAL CHECK (recovery_capacity_index BETWEEN 0 AND 1),

    notes TEXT
);

CREATE TABLE IF NOT EXISTS systemic_risk_edges (
    edge_id INTEGER PRIMARY KEY,
    source TEXT NOT NULL,
    target TEXT NOT NULL,
    relationship_type TEXT NOT NULL,
    weight REAL NOT NULL CHECK (weight BETWEEN 0 AND 1),
    dependency_criticality_index REAL CHECK (dependency_criticality_index BETWEEN 0 AND 1),
    substitutability_index REAL CHECK (substitutability_index BETWEEN 0 AND 1),

    FOREIGN KEY (source) REFERENCES systemic_risk_nodes(node),
    FOREIGN KEY (target) REFERENCES systemic_risk_nodes(node)
);

CREATE VIEW IF NOT EXISTS systemic_risk_node_fragility_view AS
SELECT
    node_id,
    node,
    system_type,
    capacity_index,
    vulnerability_index,
    exposure_index,
    governance_support_index,
    redundancy_index,
    behavioral_sensitivity_index,

    (
        0.24 * vulnerability_index +
        0.22 * exposure_index +
        0.18 * behavioral_sensitivity_index +
        0.14 * (1 - capacity_index) +
        0.12 * (1 - governance_support_index) +
        0.10 * (1 - redundancy_index)
    ) AS internal_systemic_fragility_score,

    (
        0.40 * capacity_index +
        0.30 * governance_support_index +
        0.30 * redundancy_index
    ) AS resilience_buffer_score

FROM systemic_risk_nodes;

CREATE VIEW IF NOT EXISTS systemic_risk_edge_dependency_view AS
SELECT
    edge_id,
    source,
    target,
    relationship_type,
    weight,
    dependency_criticality_index,
    substitutability_index,

    (
        0.50 * weight +
        0.30 * COALESCE(dependency_criticality_index, 0.5) +
        0.20 * (1 - COALESCE(substitutability_index, 0.5))
    ) AS dependency_pressure_score

FROM systemic_risk_edges;

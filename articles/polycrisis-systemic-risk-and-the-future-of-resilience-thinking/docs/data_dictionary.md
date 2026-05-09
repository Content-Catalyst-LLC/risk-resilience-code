# Data Dictionary

## Domain file: `polycrisis_domain_panel.csv`

| Column | Meaning |
|---|---|
| domain | Crisis domain such as climate, finance, food, health, cyber, infrastructure, ecology, migration, governance, or social cohesion |
| jurisdiction | Geographic or institutional jurisdiction |
| crisis_intensity_index | Severity of stress within the domain |
| systemic_vulnerability_index | Exposure, inequality, underinvestment, fragility, and limited buffers within the domain |
| feedback_amplification_index | Degree to which reinforcing feedback loops intensify stress |
| threshold_proximity_index | Closeness to tipping points, cascading failure, or hard-to-reverse system change |
| institutional_capacity_index | Ability to coordinate, finance, respond, learn, and adapt |
| public_legitimacy_index | Trust, fairness, accountability, competence, and willingness to cooperate |
| regenerative_capacity_index | Ability to renew ecological, social, institutional, and material foundations of resilience |
| equity_integration_index | Integration of vulnerable groups, unequal exposure, and distributional justice |
| data_auditability_index | Quality of provenance, auditability, transparency, and data trust |
| adaptive_learning_index | Ability to revise policies, plans, and institutions as evidence changes |
| maladaptation_risk_index | Risk that interventions shift harm, deepen vulnerability, or lock in fragile pathways |

## Interaction file: `polycrisis_interaction_matrix.csv`

| Column | Meaning |
|---|---|
| source_domain | Crisis domain where stress originates |
| target_domain | Crisis domain affected by the source domain |
| coupling_weight | Strength of interaction from source to target, normalized to [0, 1] |
| interaction_type | Interaction category such as cascade, feedback, common exposure, institutional overload, fiscal constraint, or legitimacy erosion |
| pathway_description | Short description of how stress moves from source to target |

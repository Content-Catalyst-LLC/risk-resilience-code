# Data Dictionary

## Node table: `systemic_risk_nodes.csv`

| Column | Meaning |
|---|---|
| node | Name or identifier of the agent, institution, infrastructure asset, firm, platform, agency, or system component |
| system_type | System category such as bank, hospital, utility, supplier, agency, platform, household, port, or public service |
| capacity_index | Internal ability to absorb stress and preserve function |
| vulnerability_index | Susceptibility to harm under stress |
| exposure_index | Degree to which the node is exposed to initiating shocks or propagated stress |
| governance_support_index | Coordination, intervention, accountability, learning, and institutional support |
| redundancy_index | Availability of backup capacity, substitutes, alternative routes, or fallback processes |
| behavioral_sensitivity_index | Likelihood that the agent amplifies stress through behavior such as panic, hoarding, withdrawal, or overload |
| modularity_support_index | Ability to isolate failure and prevent contagion |
| recovery_capacity_index | Ability to restore function after stress or failure |

## Edge table: `systemic_risk_edges.csv`

| Column | Meaning |
|---|---|
| source | Origin node of the dependency or stress pathway |
| target | Target node receiving dependency or stress |
| relationship_type | Type of connection such as financial exposure, supply dependency, power dependency, data flow, transport link, or trust relationship |
| weight | Strength of the relationship or dependency, normalized to [0, 1] |
| dependency_criticality_index | Importance of the relationship for target function |
| substitutability_index | Ease of replacing the source, relationship, supplier, route, or dependency |

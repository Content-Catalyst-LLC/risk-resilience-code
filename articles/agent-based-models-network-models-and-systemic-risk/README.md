# Agent-Based Models, Network Models, and Systemic Risk

This article directory supports the Risk & Resilience article:

**Agent-Based Models, Network Models, and Systemic Risk**

The workflows model how heterogeneous agents, network topology, dependency weights, exposure, vulnerability, capacity, behavioral response, governance support, modularity, redundancy, contagion pathways, cascading failure, and feedback loops shape systemic risk.

## Analytical Focus

The article examines:

- Agent-based models
- Network models
- Systemic risk
- Contagion pathways
- Cascading failure
- Feedback loops
- Financial systemic risk
- Critical infrastructure interdependence
- Cyber common-mode failure
- Public-health and social-system risk
- Supply-chain fragility
- Network centrality
- Dependency mapping
- Agent heterogeneity
- Behavioral amplification
- Resilience buffers
- Modularity and redundancy
- Governance support
- Model validation and ethical limits

## Suggested Input Datasets

Expected node file:

```text
systemic_risk_nodes.csv
```

Expected edge file:

```text
systemic_risk_edges.csv
```

The node file should contain normalized `*_index` values from 0 to 1.

The edge file should contain directed or undirected dependency relationships with weights.

Higher values should mean more of the named property. For example:

- `capacity_index`: higher = stronger internal resilience capacity
- `vulnerability_index`: higher = greater susceptibility to harm
- `behavioral_sensitivity_index`: higher = stronger tendency to amplify stress through behavior
- `governance_support_index`: higher = stronger coordination, intervention, accountability, and learning capacity

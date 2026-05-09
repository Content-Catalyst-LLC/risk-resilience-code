from __future__ import annotations

import random
from dataclasses import dataclass
from typing import Dict, List

import networkx as nx
import numpy as np
import pandas as pd

NODE_SUMMARY_OUTPUT = "../outputs/agent_network_systemic_fragility_summary.csv"
SIMULATION_OUTPUT = "../outputs/agent_network_systemic_risk_simulation.csv"


@dataclass
class AgentState:
    """
    State variables for a modeled agent or node.

    All index values are normalized to [0, 1].
    Higher capacity and governance reduce systemic risk.
    Higher vulnerability, exposure, and behavioral sensitivity increase systemic risk.
    """
    capacity: float
    vulnerability: float
    exposure: float
    behavioral_sensitivity: float
    governance_support: float
    stress: float = 0.0
    failed: bool = False


def clamp_01(value: float) -> float:
    """Constrain a value to the interval [0, 1]."""
    return max(0.0, min(1.0, value))


def build_system_network(
    n_agents: int = 50,
    connection_probability: float = 0.07,
    seed: int = 7,
) -> nx.DiGraph:
    """
    Build a directed weighted dependency network.

    In a real model, edges could represent interbank exposures, supplier relationships,
    infrastructure dependencies, cyber dependencies, patient transfers, data flows,
    or public-service dependencies.
    """
    random.seed(seed)
    np.random.seed(seed)

    graph = nx.gnp_random_graph(
        n=n_agents,
        p=connection_probability,
        seed=seed,
        directed=True,
    )

    for source, target in graph.edges():
        graph[source][target]["weight"] = float(np.random.uniform(0.05, 0.35))

    return graph


def assign_agent_states(graph: nx.DiGraph, seed: int = 7) -> Dict[int, AgentState]:
    """
    Assign heterogeneous capacity, vulnerability, exposure, behavior, and governance values.
    """
    random.seed(seed)
    np.random.seed(seed)

    states: Dict[int, AgentState] = {}

    for node in graph.nodes():
        states[node] = AgentState(
            capacity=float(np.random.uniform(0.35, 0.90)),
            vulnerability=float(np.random.uniform(0.10, 0.75)),
            exposure=float(np.random.uniform(0.10, 0.85)),
            behavioral_sensitivity=float(np.random.uniform(0.05, 0.70)),
            governance_support=float(np.random.uniform(0.25, 0.90)),
        )

    return states


def apply_initial_shock(
    states: Dict[int, AgentState],
    shocked_nodes: List[int],
    shock_intensity: float,
) -> None:
    """Apply an initial shock to selected agents."""
    for node in shocked_nodes:
        agent = states[node]

        initial_stress = (
            shock_intensity
            * agent.exposure
            * (0.50 + 0.50 * agent.vulnerability)
            * (1.0 - 0.40 * agent.capacity)
        )

        agent.stress = clamp_01(agent.stress + initial_stress)


def update_failures(
    states: Dict[int, AgentState],
    failure_threshold: float = 0.75,
) -> None:
    """Mark agents as failed when stress exceeds threshold."""
    for agent in states.values():
        if agent.stress >= failure_threshold:
            agent.failed = True


def propagate_stress(
    graph: nx.DiGraph,
    states: Dict[int, AgentState],
    behavioral_amplification: float = 0.35,
    governance_damping: float = 0.30,
) -> Dict[int, float]:
    """
    Propagate stress through weighted network dependencies.

    Stress transmitted to a target increases with:
    - source stress
    - edge dependency weight
    - target vulnerability
    - target behavioral sensitivity

    Stress is dampened by:
    - target capacity
    - target governance support
    """
    incoming_stress: Dict[int, float] = {node: 0.0 for node in graph.nodes()}

    for source, target, data in graph.edges(data=True):
        source_agent = states[source]
        target_agent = states[target]
        weight = float(data.get("weight", 0.0))

        behavioral_term = 1.0 + behavioral_amplification * target_agent.behavioral_sensitivity
        damping_term = (
            1.0
            - 0.45 * target_agent.capacity
            - governance_damping * target_agent.governance_support
        )

        transmitted = (
            source_agent.stress
            * weight
            * (0.50 + target_agent.vulnerability)
            * behavioral_term
            * max(0.05, damping_term)
        )

        incoming_stress[target] += transmitted

    return incoming_stress


def simulate_systemic_risk(
    graph: nx.DiGraph,
    states: Dict[int, AgentState],
    shocked_nodes: List[int],
    shock_intensity: float = 0.90,
    n_steps: int = 15,
    recovery_rate: float = 0.05,
) -> pd.DataFrame:
    """
    Simulate systemic-risk propagation over time.

    Recovery is simplified as a constant stress-reduction term multiplied by capacity
    and governance support.
    """
    apply_initial_shock(states, shocked_nodes, shock_intensity)

    records = []

    for step in range(n_steps + 1):
        update_failures(states)

        total_stress = sum(agent.stress for agent in states.values())
        failed_agents = sum(agent.failed for agent in states.values())
        mean_stress = np.mean([agent.stress for agent in states.values()])

        records.append(
            {
                "step": step,
                "total_system_stress": total_stress,
                "mean_agent_stress": mean_stress,
                "failed_agents": failed_agents,
                "failed_share": failed_agents / len(states),
            }
        )

        incoming = propagate_stress(graph, states)

        for node, agent in states.items():
            recovery = recovery_rate * agent.capacity * (0.50 + agent.governance_support)
            agent.stress = clamp_01(agent.stress + incoming[node] - recovery)

    return pd.DataFrame(records)


def summarize_network(graph: nx.DiGraph, states: Dict[int, AgentState]) -> pd.DataFrame:
    """Create a node-level systemic importance and fragility summary."""
    pagerank = nx.pagerank(graph, weight="weight")
    betweenness = nx.betweenness_centrality(graph, weight="weight", normalized=True)
    in_strength = dict(graph.in_degree(weight="weight"))
    out_strength = dict(graph.out_degree(weight="weight"))

    rows = []

    for node, agent in states.items():
        systemic_fragility_score = (
            0.25 * agent.vulnerability
            + 0.20 * agent.exposure
            + 0.20 * agent.behavioral_sensitivity
            + 0.15 * pagerank[node]
            + 0.10 * betweenness[node]
            + 0.10 * (1 - agent.capacity)
        )

        rows.append(
            {
                "node": node,
                "capacity": agent.capacity,
                "vulnerability": agent.vulnerability,
                "exposure": agent.exposure,
                "behavioral_sensitivity": agent.behavioral_sensitivity,
                "governance_support": agent.governance_support,
                "pagerank": pagerank[node],
                "betweenness": betweenness[node],
                "in_strength": in_strength.get(node, 0.0),
                "out_strength": out_strength.get(node, 0.0),
                "systemic_fragility_score": systemic_fragility_score,
            }
        )

    return (
        pd.DataFrame(rows)
        .sort_values("systemic_fragility_score", ascending=False)
        .reset_index(drop=True)
    )


def main() -> None:
    graph = build_system_network(n_agents=50, connection_probability=0.07, seed=7)
    states = assign_agent_states(graph, seed=7)

    node_summary = summarize_network(graph, states)
    high_fragility_nodes = node_summary.head(3)["node"].tolist()

    simulation = simulate_systemic_risk(
        graph=graph,
        states=states,
        shocked_nodes=high_fragility_nodes,
        shock_intensity=0.90,
        n_steps=15,
        recovery_rate=0.05,
    )

    node_summary.to_csv(NODE_SUMMARY_OUTPUT, index=False)
    simulation.to_csv(SIMULATION_OUTPUT, index=False)

    print("Top systemic-fragility nodes:")
    print(node_summary.head(10).to_string(index=False))

    print("\nSystemic-risk simulation:")
    print(simulation.to_string(index=False))


if __name__ == "__main__":
    main()

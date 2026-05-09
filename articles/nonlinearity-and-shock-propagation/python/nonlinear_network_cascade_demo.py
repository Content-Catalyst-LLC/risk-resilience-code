from __future__ import annotations

import random
from dataclasses import dataclass

import networkx as nx


@dataclass
class CascadeConfig:
    node_count: int = 20
    edge_probability: float = 0.12
    initial_shock_node: int = 0
    initial_shock_intensity: float = 0.65
    threshold: float = 0.80
    propagation_factor: float = 0.45
    steps: int = 8
    seed: int = 42


def build_network(config: CascadeConfig) -> nx.Graph:
    """Build a connected random graph for demonstration."""
    random.seed(config.seed)
    graph = nx.erdos_renyi_graph(
        n=config.node_count,
        p=config.edge_probability,
        seed=config.seed,
    )

    if not nx.is_connected(graph):
        largest_component = max(nx.connected_components(graph), key=len)
        graph = graph.subgraph(largest_component).copy()

    for node in graph.nodes:
        graph.nodes[node]["stress"] = 0.0
        graph.nodes[node]["failed"] = False

    return graph


def simulate_cascade(config: CascadeConfig) -> list[dict]:
    """
    Simulate a simple nonlinear cascade.

    When node stress crosses the threshold, the node fails and transmits stress
    to neighbors. This is a conceptual illustration, not a predictive model.
    """
    graph = build_network(config)

    if config.initial_shock_node not in graph.nodes:
        config.initial_shock_node = next(iter(graph.nodes))

    graph.nodes[config.initial_shock_node]["stress"] = config.initial_shock_intensity

    records = []

    for step in range(config.steps):
        newly_failed = []

        for node in graph.nodes:
            if (
                graph.nodes[node]["stress"] >= config.threshold
                and not graph.nodes[node]["failed"]
            ):
                graph.nodes[node]["failed"] = True
                newly_failed.append(node)

        for node in newly_failed:
            for neighbor in graph.neighbors(node):
                if not graph.nodes[neighbor]["failed"]:
                    degree_pressure = graph.degree(node) / max(1, graph.number_of_nodes() - 1)
                    graph.nodes[neighbor]["stress"] += (
                        config.propagation_factor * (1 + degree_pressure)
                    )

        failed_count = sum(1 for node in graph.nodes if graph.nodes[node]["failed"])
        max_stress = max(graph.nodes[node]["stress"] for node in graph.nodes)

        records.append(
            {
                "step": step,
                "newly_failed": newly_failed,
                "failed_count": failed_count,
                "max_stress": round(max_stress, 3),
            }
        )

    return records


def main() -> None:
    config = CascadeConfig()
    results = simulate_cascade(config)

    print("Nonlinear network cascade demonstration")
    for row in results:
        print(row)


if __name__ == "__main__":
    main()

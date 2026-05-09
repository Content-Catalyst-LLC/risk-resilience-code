from __future__ import annotations

from dataclasses import dataclass
import networkx as nx


@dataclass
class CouplingCascadeConfig:
    node_count: int = 18
    edge_probability: float = 0.18
    seed: int = 42
    initial_failed_node: int = 0
    coupling_strength: float = 0.72
    buffering_capacity: float = 0.28
    failure_threshold: float = 0.65
    steps: int = 8


def build_coupled_network(config: CouplingCascadeConfig) -> nx.Graph:
    """Build a connected random graph for conceptual cascade simulation."""
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


def simulate_tight_coupling(config: CouplingCascadeConfig) -> list[dict]:
    """
    Simulate a simple tight-coupling cascade.

    Failure spreads when transmitted stress exceeds buffering capacity.
    This is a conceptual illustration, not a predictive model.
    """
    graph = build_coupled_network(config)

    if config.initial_failed_node not in graph.nodes:
        config.initial_failed_node = next(iter(graph.nodes))

    graph.nodes[config.initial_failed_node]["failed"] = True
    graph.nodes[config.initial_failed_node]["stress"] = 1.0

    records = []

    for step in range(config.steps):
        newly_failed = []

        for node in list(graph.nodes):
            if not graph.nodes[node]["failed"]:
                failed_neighbors = sum(
                    1 for neighbor in graph.neighbors(node)
                    if graph.nodes[neighbor]["failed"]
                )
                degree = max(1, graph.degree(node))
                transmitted_stress = (
                    failed_neighbors / degree
                ) * config.coupling_strength

                residual_stress = max(
                    0.0,
                    transmitted_stress - config.buffering_capacity
                )

                graph.nodes[node]["stress"] += residual_stress

                if graph.nodes[node]["stress"] >= config.failure_threshold:
                    newly_failed.append(node)

        for node in newly_failed:
            graph.nodes[node]["failed"] = True

        failed_count = sum(
            1 for node in graph.nodes if graph.nodes[node]["failed"]
        )

        records.append(
            {
                "step": step,
                "newly_failed": newly_failed,
                "failed_count": failed_count,
                "network_size": graph.number_of_nodes(),
            }
        )

    return records


def main() -> None:
    config = CouplingCascadeConfig()
    results = simulate_tight_coupling(config)

    print("Tight-coupling cascade demonstration")
    for row in results:
        print(row)


if __name__ == "__main__":
    main()

library(readr)
library(dplyr)
library(igraph)

edge_file <- "../data/raw/systemic_risk_edges.csv"
node_file <- "../data/raw/systemic_risk_nodes.csv"

diagnostics_output_file <- "../outputs/network_systemic_fragility_diagnostics.csv"
summary_output_file <- "../outputs/network_systemic_fragility_system_type_summary.csv"

edge_df <- read_csv(edge_file, show_col_types = FALSE)
node_df <- read_csv(node_file, show_col_types = FALSE)

required_edge_cols <- c("source", "target", "weight")
required_node_cols <- c(
  "node",
  "system_type",
  "capacity_index",
  "vulnerability_index",
  "exposure_index",
  "governance_support_index",
  "redundancy_index",
  "behavioral_sensitivity_index"
)

missing_edge_cols <- setdiff(required_edge_cols, names(edge_df))
missing_node_cols <- setdiff(required_node_cols, names(node_df))

if (length(missing_edge_cols) > 0) {
  stop(paste("Missing edge columns:", paste(missing_edge_cols, collapse = ", ")))
}

if (length(missing_node_cols) > 0) {
  stop(paste("Missing node columns:", paste(missing_node_cols, collapse = ", ")))
}

index_cols <- names(node_df)[grepl("_index$", names(node_df))]

invalid_index_cols <- index_cols[
  vapply(
    node_df[index_cols],
    function(x) any(is.na(x) | x < 0 | x > 1),
    logical(1)
  )
]

if (length(invalid_index_cols) > 0) {
  stop(
    paste(
      "Index columns must be complete and normalized to [0, 1]:",
      paste(invalid_index_cols, collapse = ", ")
    )
  )
}

graph <- graph_from_data_frame(
  d = edge_df,
  vertices = node_df,
  directed = TRUE
)

E(graph)$weight <- edge_df$weight

node_metrics <- tibble(
  node = V(graph)$name,
  degree_total = degree(graph, mode = "all"),
  degree_in = degree(graph, mode = "in"),
  degree_out = degree(graph, mode = "out"),
  strength_in = strength(graph, mode = "in", weights = E(graph)$weight),
  strength_out = strength(graph, mode = "out", weights = E(graph)$weight),
  betweenness = betweenness(graph, directed = TRUE, weights = E(graph)$weight, normalized = TRUE),
  page_rank = page_rank(graph, directed = TRUE, weights = E(graph)$weight)$vector
)

diagnostics <- node_df %>%
  left_join(node_metrics, by = "node") %>%
  mutate(
    centrality_pressure = percent_rank(page_rank + betweenness + strength_in + strength_out),
    internal_fragility = (
      vulnerability_index +
        exposure_index +
        behavioral_sensitivity_index +
        (1 - capacity_index) +
        (1 - governance_support_index) +
        (1 - redundancy_index)
    ) / 6,
    systemic_fragility_score = (
      0.35 * internal_fragility +
        0.25 * centrality_pressure +
        0.15 * behavioral_sensitivity_index +
        0.15 * vulnerability_index +
        0.10 * exposure_index
    ),
    resilience_buffer_score = (
      capacity_index +
        governance_support_index +
        redundancy_index
    ) / 3,
    systemic_risk_band = case_when(
      systemic_fragility_score >= 0.75 ~ "Extreme systemic fragility",
      systemic_fragility_score >= 0.55 ~ "High systemic fragility",
      systemic_fragility_score >= 0.35 ~ "Moderate systemic fragility",
      TRUE ~ "Lower systemic fragility"
    )
  ) %>%
  arrange(desc(systemic_fragility_score))

system_type_summary <- diagnostics %>%
  group_by(system_type) %>%
  summarise(
    avg_systemic_fragility = mean(systemic_fragility_score, na.rm = TRUE),
    avg_resilience_buffer = mean(resilience_buffer_score, na.rm = TRUE),
    avg_centrality_pressure = mean(centrality_pressure, na.rm = TRUE),
    avg_internal_fragility = mean(internal_fragility, na.rm = TRUE),
    avg_capacity = mean(capacity_index, na.rm = TRUE),
    avg_vulnerability = mean(vulnerability_index, na.rm = TRUE),
    avg_exposure = mean(exposure_index, na.rm = TRUE),
    avg_governance_support = mean(governance_support_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_systemic_fragility))

write_csv(diagnostics, diagnostics_output_file)
write_csv(system_type_summary, summary_output_file)

cat("Node-level systemic fragility diagnostics exported to:", diagnostics_output_file, "\n")
print(diagnostics)

cat("\nSystem-type summary exported to:", summary_output_file, "\n")
print(system_type_summary)

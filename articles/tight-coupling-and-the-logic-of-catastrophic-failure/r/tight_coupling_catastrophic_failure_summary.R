library(readr)
library(dplyr)

input_file <- "../data/raw/tight_coupling_catastrophic_failure_panel.csv"
sector_output_file <- "../outputs/tight_coupling_sector_summary.csv"
system_type_output_file <- "../outputs/tight_coupling_system_type_summary.csv"

coupling_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "system_name",
  "sector",
  "system_type",
  "coupling_strength_index",
  "time_compression_index",
  "sequence_rigidity_index",
  "limited_substitution_index",
  "interactive_complexity_index",
  "hidden_dependency_index",
  "critical_node_importance_index",
  "buffering_index",
  "modularity_index",
  "redundancy_index",
  "adaptive_authority_index",
  "fallback_capacity_index"
)

missing_cols <- setdiff(required_cols, names(coupling_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(coupling_df)[grepl("_index$", names(coupling_df))]

invalid_index_cols <- index_cols[
  vapply(
    coupling_df[index_cols],
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

coupling_df <- coupling_df %>%
  mutate(
    tight_coupling_pressure_proxy = (
      coupling_strength_index +
        time_compression_index +
        sequence_rigidity_index +
        limited_substitution_index +
        interactive_complexity_index +
        hidden_dependency_index +
        critical_node_importance_index
    ) / 7,
    resilience_room_proxy = (
      buffering_index +
        modularity_index +
        redundancy_index +
        adaptive_authority_index +
        fallback_capacity_index
    ) / 5,
    catastrophic_failure_risk_proxy = (
      tight_coupling_pressure_proxy +
        (1 - resilience_room_proxy)
    ) / 2,
    containment_margin = resilience_room_proxy -
      tight_coupling_pressure_proxy,
    failure_risk_band = case_when(
      catastrophic_failure_risk_proxy >= 0.75 ~ "Severe tight-coupling catastrophic-failure risk",
      catastrophic_failure_risk_proxy >= 0.55 ~ "High tight-coupling catastrophic-failure risk",
      catastrophic_failure_risk_proxy >= 0.35 ~ "Moderate tight-coupling catastrophic-failure risk",
      TRUE ~ "Lower tight-coupling catastrophic-failure risk"
    )
  )

sector_summary <- coupling_df %>%
  group_by(sector) %>%
  summarise(
    avg_catastrophic_failure_risk = mean(catastrophic_failure_risk_proxy, na.rm = TRUE),
    avg_tight_coupling_pressure = mean(tight_coupling_pressure_proxy, na.rm = TRUE),
    avg_resilience_room = mean(resilience_room_proxy, na.rm = TRUE),
    avg_containment_margin = mean(containment_margin, na.rm = TRUE),
    avg_coupling_strength = mean(coupling_strength_index, na.rm = TRUE),
    avg_time_compression = mean(time_compression_index, na.rm = TRUE),
    avg_sequence_rigidity = mean(sequence_rigidity_index, na.rm = TRUE),
    avg_limited_substitution = mean(limited_substitution_index, na.rm = TRUE),
    avg_interactive_complexity = mean(interactive_complexity_index, na.rm = TRUE),
    avg_hidden_dependency = mean(hidden_dependency_index, na.rm = TRUE),
    avg_critical_node_importance = mean(critical_node_importance_index, na.rm = TRUE),
    avg_buffering = mean(buffering_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_adaptive_authority = mean(adaptive_authority_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_catastrophic_failure_risk))

system_type_summary <- coupling_df %>%
  group_by(system_type) %>%
  summarise(
    avg_catastrophic_failure_risk = mean(catastrophic_failure_risk_proxy, na.rm = TRUE),
    avg_tight_coupling_pressure = mean(tight_coupling_pressure_proxy, na.rm = TRUE),
    avg_resilience_room = mean(resilience_room_proxy, na.rm = TRUE),
    avg_containment_margin = mean(containment_margin, na.rm = TRUE),
    avg_coupling_strength = mean(coupling_strength_index, na.rm = TRUE),
    avg_time_compression = mean(time_compression_index, na.rm = TRUE),
    avg_sequence_rigidity = mean(sequence_rigidity_index, na.rm = TRUE),
    avg_limited_substitution = mean(limited_substitution_index, na.rm = TRUE),
    avg_interactive_complexity = mean(interactive_complexity_index, na.rm = TRUE),
    avg_hidden_dependency = mean(hidden_dependency_index, na.rm = TRUE),
    avg_critical_node_importance = mean(critical_node_importance_index, na.rm = TRUE),
    avg_buffering = mean(buffering_index, na.rm = TRUE),
    avg_modularity = mean(modularity_index, na.rm = TRUE),
    avg_redundancy = mean(redundancy_index, na.rm = TRUE),
    avg_adaptive_authority = mean(adaptive_authority_index, na.rm = TRUE),
    avg_fallback_capacity = mean(fallback_capacity_index, na.rm = TRUE),
    systems = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_tight_coupling_pressure))

write_csv(sector_summary, sector_output_file)
write_csv(system_type_summary, system_type_output_file)

cat("Tight-coupling sector summary exported to:", sector_output_file, "\n")
print(sector_summary)

cat("\nTight-coupling system-type summary exported to:", system_type_output_file, "\n")
print(system_type_summary)

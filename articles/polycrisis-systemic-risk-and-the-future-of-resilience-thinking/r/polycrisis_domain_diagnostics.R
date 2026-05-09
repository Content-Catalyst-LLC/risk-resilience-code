library(readr)
library(dplyr)

domain_file <- "../data/raw/polycrisis_domain_panel.csv"
interaction_file <- "../data/raw/polycrisis_interaction_matrix.csv"

domain_output_file <- "../outputs/polycrisis_domain_diagnostics.csv"
jurisdiction_output_file <- "../outputs/polycrisis_jurisdiction_summary.csv"
interaction_output_file <- "../outputs/polycrisis_interaction_diagnostics.csv"

domain_df <- read_csv(domain_file, show_col_types = FALSE)
interaction_df <- read_csv(interaction_file, show_col_types = FALSE)

required_domain_cols <- c(
  "domain",
  "jurisdiction",
  "crisis_intensity_index",
  "systemic_vulnerability_index",
  "feedback_amplification_index",
  "threshold_proximity_index",
  "institutional_capacity_index",
  "public_legitimacy_index",
  "regenerative_capacity_index",
  "equity_integration_index",
  "data_auditability_index",
  "adaptive_learning_index",
  "maladaptation_risk_index"
)

required_interaction_cols <- c(
  "source_domain",
  "target_domain",
  "coupling_weight"
)

missing_domain_cols <- setdiff(required_domain_cols, names(domain_df))
missing_interaction_cols <- setdiff(required_interaction_cols, names(interaction_df))

if (length(missing_domain_cols) > 0) {
  stop(paste("Missing domain columns:", paste(missing_domain_cols, collapse = ", ")))
}

if (length(missing_interaction_cols) > 0) {
  stop(paste("Missing interaction columns:", paste(missing_interaction_cols, collapse = ", ")))
}

index_cols <- names(domain_df)[grepl("_index$", names(domain_df))]

invalid_index_cols <- index_cols[
  vapply(
    domain_df[index_cols],
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

if (any(is.na(interaction_df$coupling_weight) | interaction_df$coupling_weight < 0 | interaction_df$coupling_weight > 1)) {
  stop("coupling_weight must be complete and normalized to [0, 1].")
}

domain_scores <- domain_df %>%
  mutate(
    domain_polycrisis_pressure = (
      crisis_intensity_index +
        systemic_vulnerability_index +
        feedback_amplification_index +
        threshold_proximity_index +
        maladaptation_risk_index +
        (1 - institutional_capacity_index)
    ) / 6,
    transformative_resilience = (
      institutional_capacity_index +
        public_legitimacy_index +
        regenerative_capacity_index +
        equity_integration_index +
        data_auditability_index +
        adaptive_learning_index +
        (1 - maladaptation_risk_index)
    ) / 7,
    resilience_gap = transformative_resilience - domain_polycrisis_pressure,
    domain_band = case_when(
      domain_polycrisis_pressure >= 0.75 ~ "Severe domain pressure",
      domain_polycrisis_pressure >= 0.55 ~ "High domain pressure",
      domain_polycrisis_pressure >= 0.35 ~ "Moderate domain pressure",
      TRUE ~ "Lower domain pressure"
    )
  )

pressure_lookup <- domain_scores %>%
  select(domain, domain_polycrisis_pressure)

interaction_scores <- interaction_df %>%
  left_join(
    pressure_lookup,
    by = c("source_domain" = "domain")
  ) %>%
  rename(source_pressure = domain_polycrisis_pressure) %>%
  left_join(
    pressure_lookup,
    by = c("target_domain" = "domain")
  ) %>%
  rename(target_pressure = domain_polycrisis_pressure) %>%
  mutate(
    interaction_pressure = source_pressure * target_pressure * coupling_weight
  ) %>%
  arrange(desc(interaction_pressure))

interaction_summary <- interaction_scores %>%
  summarise(
    total_interaction_pressure = sum(interaction_pressure, na.rm = TRUE),
    avg_interaction_pressure = mean(interaction_pressure, na.rm = TRUE),
    max_interaction_pressure = max(interaction_pressure, na.rm = TRUE),
    interactions = n()
  )

jurisdiction_summary <- domain_scores %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_domain_polycrisis_pressure = mean(domain_polycrisis_pressure, na.rm = TRUE),
    max_domain_polycrisis_pressure = max(domain_polycrisis_pressure, na.rm = TRUE),
    avg_transformative_resilience = mean(transformative_resilience, na.rm = TRUE),
    min_transformative_resilience = min(transformative_resilience, na.rm = TRUE),
    avg_resilience_gap = mean(resilience_gap, na.rm = TRUE),
    avg_crisis_intensity = mean(crisis_intensity_index, na.rm = TRUE),
    avg_systemic_vulnerability = mean(systemic_vulnerability_index, na.rm = TRUE),
    avg_feedback_amplification = mean(feedback_amplification_index, na.rm = TRUE),
    avg_threshold_proximity = mean(threshold_proximity_index, na.rm = TRUE),
    avg_institutional_capacity = mean(institutional_capacity_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_regenerative_capacity = mean(regenerative_capacity_index, na.rm = TRUE),
    avg_equity_integration = mean(equity_integration_index, na.rm = TRUE),
    avg_data_auditability = mean(data_auditability_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    domains = n(),
    .groups = "drop"
  ) %>%
  mutate(
    avg_interaction_pressure = interaction_summary$avg_interaction_pressure[1],
    max_interaction_pressure = interaction_summary$max_interaction_pressure[1],
    overall_polycrisis_pressure = (
      0.50 * avg_domain_polycrisis_pressure +
        0.25 * max_domain_polycrisis_pressure +
        0.15 * avg_interaction_pressure +
        0.10 * max_interaction_pressure
    ),
    polycrisis_resilience_readiness = (
      0.40 * avg_transformative_resilience +
        0.20 * min_transformative_resilience +
        0.15 * avg_public_legitimacy +
        0.10 * avg_regenerative_capacity +
        0.10 * avg_data_auditability +
        0.05 * avg_equity_integration
    ),
    readiness_gap = polycrisis_resilience_readiness - overall_polycrisis_pressure,
    polycrisis_band = case_when(
      overall_polycrisis_pressure >= 0.75 ~ "Severe polycrisis pressure",
      overall_polycrisis_pressure >= 0.55 ~ "High polycrisis pressure",
      overall_polycrisis_pressure >= 0.35 ~ "Moderate polycrisis pressure",
      TRUE ~ "Lower polycrisis pressure"
    )
  ) %>%
  arrange(desc(overall_polycrisis_pressure))

write_csv(domain_scores, domain_output_file)
write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(interaction_scores, interaction_output_file)

cat("Polycrisis domain diagnostics exported to:", domain_output_file, "\n")
print(domain_scores)

cat("\nPolycrisis jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nPolycrisis interaction diagnostics exported to:", interaction_output_file, "\n")
print(interaction_scores)

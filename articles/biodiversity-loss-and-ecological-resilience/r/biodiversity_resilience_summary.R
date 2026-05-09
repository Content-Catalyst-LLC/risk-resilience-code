library(readr)
library(dplyr)

input_file <- "../data/raw/biodiversity_ecological_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/biodiversity_resilience_jurisdiction_summary.csv"
ecosystem_output_file <- "../outputs/biodiversity_resilience_ecosystem_type_summary.csv"

bio_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "ecosystem_name",
  "jurisdiction",
  "ecosystem_type",
  "genetic_diversity_index",
  "species_diversity_index",
  "functional_diversity_index",
  "habitat_connectivity_index",
  "ecosystem_integrity_index",
  "adaptive_capacity_index",
  "governance_quality_index",
  "community_stewardship_index",
  "fragmentation_pressure_index",
  "pollution_pressure_index",
  "invasive_pressure_index",
  "extraction_pressure_index",
  "climate_stress_index",
  "monitoring_gap_index"
)

missing_cols <- setdiff(required_cols, names(bio_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(bio_df)[grepl("_index$", names(bio_df))]

invalid_index_cols <- index_cols[
  vapply(
    bio_df[index_cols],
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

bio_df <- bio_df %>%
  mutate(
    biodiversity_resilience_proxy = (
      genetic_diversity_index +
        species_diversity_index +
        functional_diversity_index +
        habitat_connectivity_index +
        ecosystem_integrity_index +
        adaptive_capacity_index +
        governance_quality_index +
        community_stewardship_index
    ) / 8,
    ecological_pressure_proxy = (
      fragmentation_pressure_index +
        pollution_pressure_index +
        invasive_pressure_index +
        extraction_pressure_index +
        climate_stress_index +
        monitoring_gap_index
    ) / 6,
    ecological_resilience_gap = biodiversity_resilience_proxy -
      ecological_pressure_proxy,
    resilience_band = case_when(
      biodiversity_resilience_proxy >= 0.75 ~ "Strong biodiversity-supported resilience",
      biodiversity_resilience_proxy >= 0.55 ~ "Moderate biodiversity-supported resilience",
      biodiversity_resilience_proxy >= 0.35 ~ "Limited biodiversity-supported resilience",
      TRUE ~ "Weak biodiversity-supported resilience"
    )
  )

jurisdiction_summary <- bio_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_biodiversity_resilience = mean(biodiversity_resilience_proxy, na.rm = TRUE),
    avg_ecological_pressure = mean(ecological_pressure_proxy, na.rm = TRUE),
    avg_ecological_resilience_gap = mean(ecological_resilience_gap, na.rm = TRUE),
    avg_genetic_diversity = mean(genetic_diversity_index, na.rm = TRUE),
    avg_species_diversity = mean(species_diversity_index, na.rm = TRUE),
    avg_functional_diversity = mean(functional_diversity_index, na.rm = TRUE),
    avg_habitat_connectivity = mean(habitat_connectivity_index, na.rm = TRUE),
    avg_ecosystem_integrity = mean(ecosystem_integrity_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_fragmentation_pressure = mean(fragmentation_pressure_index, na.rm = TRUE),
    avg_pollution_pressure = mean(pollution_pressure_index, na.rm = TRUE),
    avg_invasive_pressure = mean(invasive_pressure_index, na.rm = TRUE),
    avg_extraction_pressure = mean(extraction_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_ecological_resilience_gap))

ecosystem_summary <- bio_df %>%
  group_by(ecosystem_type) %>%
  summarise(
    avg_biodiversity_resilience = mean(biodiversity_resilience_proxy, na.rm = TRUE),
    avg_ecological_pressure = mean(ecological_pressure_proxy, na.rm = TRUE),
    avg_ecological_resilience_gap = mean(ecological_resilience_gap, na.rm = TRUE),
    avg_genetic_diversity = mean(genetic_diversity_index, na.rm = TRUE),
    avg_species_diversity = mean(species_diversity_index, na.rm = TRUE),
    avg_functional_diversity = mean(functional_diversity_index, na.rm = TRUE),
    avg_habitat_connectivity = mean(habitat_connectivity_index, na.rm = TRUE),
    avg_ecosystem_integrity = mean(ecosystem_integrity_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_fragmentation_pressure = mean(fragmentation_pressure_index, na.rm = TRUE),
    avg_pollution_pressure = mean(pollution_pressure_index, na.rm = TRUE),
    avg_invasive_pressure = mean(invasive_pressure_index, na.rm = TRUE),
    avg_extraction_pressure = mean(extraction_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_ecological_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(ecosystem_summary, ecosystem_output_file)

cat("Biodiversity resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nBiodiversity resilience ecosystem-type summary exported to:", ecosystem_output_file, "\n")
print(ecosystem_summary)

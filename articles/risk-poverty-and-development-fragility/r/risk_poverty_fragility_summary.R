library(readr)
library(dplyr)

input_file <- "../data/raw/risk_poverty_development_fragility_panel.csv"
jurisdiction_output_file <- "../outputs/risk_poverty_fragility_jurisdiction_summary.csv"
place_type_output_file <- "../outputs/risk_poverty_fragility_place_type_summary.csv"

fragility_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "place_name",
  "jurisdiction",
  "place_type",
  "risk_exposure_index",
  "multidimensional_poverty_index",
  "institutional_weakness_index",
  "livelihood_precarity_index",
  "service_deficit_index",
  "conflict_pressure_index",
  "climate_stress_index",
  "displacement_pressure_index",
  "social_protection_index",
  "household_buffer_index",
  "adaptive_capacity_index",
  "service_continuity_index",
  "institutional_trust_index",
  "community_voice_index"
)

missing_cols <- setdiff(required_cols, names(fragility_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(fragility_df)[grepl("_index$", names(fragility_df))]

invalid_index_cols <- index_cols[
  vapply(
    fragility_df[index_cols],
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

fragility_df <- fragility_df %>%
  mutate(
    development_fragility_proxy = (
      risk_exposure_index +
        multidimensional_poverty_index +
        institutional_weakness_index +
        livelihood_precarity_index +
        service_deficit_index +
        conflict_pressure_index +
        climate_stress_index +
        displacement_pressure_index
    ) / 8,
    resilience_sufficiency_proxy = (
      social_protection_index +
        household_buffer_index +
        adaptive_capacity_index +
        service_continuity_index +
        institutional_trust_index +
        community_voice_index
    ) / 6,
    poverty_fragility_gap = resilience_sufficiency_proxy -
      development_fragility_proxy,
    fragility_band = case_when(
      development_fragility_proxy >= 0.75 ~ "Extreme development fragility",
      development_fragility_proxy >= 0.55 ~ "High development fragility",
      development_fragility_proxy >= 0.35 ~ "Moderate development fragility",
      TRUE ~ "Lower development fragility"
    )
  )

jurisdiction_summary <- fragility_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_development_fragility = mean(development_fragility_proxy, na.rm = TRUE),
    avg_resilience_sufficiency = mean(resilience_sufficiency_proxy, na.rm = TRUE),
    avg_poverty_fragility_gap = mean(poverty_fragility_gap, na.rm = TRUE),
    avg_risk_exposure = mean(risk_exposure_index, na.rm = TRUE),
    avg_multidimensional_poverty = mean(multidimensional_poverty_index, na.rm = TRUE),
    avg_institutional_weakness = mean(institutional_weakness_index, na.rm = TRUE),
    avg_livelihood_precarity = mean(livelihood_precarity_index, na.rm = TRUE),
    avg_service_deficit = mean(service_deficit_index, na.rm = TRUE),
    avg_conflict_pressure = mean(conflict_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    avg_displacement_pressure = mean(displacement_pressure_index, na.rm = TRUE),
    avg_social_protection = mean(social_protection_index, na.rm = TRUE),
    avg_household_buffers = mean(household_buffer_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_service_continuity = mean(service_continuity_index, na.rm = TRUE),
    avg_institutional_trust = mean(institutional_trust_index, na.rm = TRUE),
    avg_community_voice = mean(community_voice_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_development_fragility))

place_type_summary <- fragility_df %>%
  group_by(place_type) %>%
  summarise(
    avg_development_fragility = mean(development_fragility_proxy, na.rm = TRUE),
    avg_resilience_sufficiency = mean(resilience_sufficiency_proxy, na.rm = TRUE),
    avg_poverty_fragility_gap = mean(poverty_fragility_gap, na.rm = TRUE),
    avg_risk_exposure = mean(risk_exposure_index, na.rm = TRUE),
    avg_multidimensional_poverty = mean(multidimensional_poverty_index, na.rm = TRUE),
    avg_institutional_weakness = mean(institutional_weakness_index, na.rm = TRUE),
    avg_livelihood_precarity = mean(livelihood_precarity_index, na.rm = TRUE),
    avg_service_deficit = mean(service_deficit_index, na.rm = TRUE),
    avg_conflict_pressure = mean(conflict_pressure_index, na.rm = TRUE),
    avg_climate_stress = mean(climate_stress_index, na.rm = TRUE),
    avg_displacement_pressure = mean(displacement_pressure_index, na.rm = TRUE),
    avg_social_protection = mean(social_protection_index, na.rm = TRUE),
    avg_household_buffers = mean(household_buffer_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_service_continuity = mean(service_continuity_index, na.rm = TRUE),
    avg_institutional_trust = mean(institutional_trust_index, na.rm = TRUE),
    avg_community_voice = mean(community_voice_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(avg_poverty_fragility_gap)

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(place_type_summary, place_type_output_file)

cat("Risk, poverty, and fragility jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nRisk, poverty, and fragility place-type summary exported to:", place_type_output_file, "\n")
print(place_type_summary)

library(readr)
library(dplyr)

input_file <- "../data/raw/inequality_resilience_panel.csv"
jurisdiction_output_file <- "../outputs/inequality_resilience_jurisdiction_summary.csv"
place_type_output_file <- "../outputs/inequality_resilience_place_type_summary.csv"

ineq_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "place_name",
  "jurisdiction",
  "place_type",
  "system_capacity_index",
  "distributed_protection_index",
  "household_buffer_index",
  "service_access_index",
  "institutional_trust_index",
  "adaptive_capacity_index",
  "social_protection_index",
  "community_voice_index",
  "exposure_concentration_index",
  "multidimensional_deprivation_index",
  "social_exclusion_index",
  "recovery_inequality_index",
  "digital_exclusion_index",
  "fiscal_stress_index"
)

missing_cols <- setdiff(required_cols, names(ineq_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(ineq_df)[grepl("_index$", names(ineq_df))]

invalid_index_cols <- index_cols[
  vapply(
    ineq_df[index_cols],
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

ineq_df <- ineq_df %>%
  mutate(
    aggregate_resilience_capacity_proxy = (
      system_capacity_index +
        service_access_index +
        adaptive_capacity_index +
        social_protection_index +
        institutional_trust_index +
        household_buffer_index +
        community_voice_index
    ) / 7,
    inequality_pressure_proxy = (
      exposure_concentration_index +
        multidimensional_deprivation_index +
        social_exclusion_index +
        recovery_inequality_index +
        digital_exclusion_index +
        fiscal_stress_index
    ) / 6,
    equality_adjusted_resilience_proxy = (
      system_capacity_index +
        distributed_protection_index +
        household_buffer_index +
        service_access_index +
        institutional_trust_index +
        adaptive_capacity_index +
        social_protection_index +
        community_voice_index +
        (1 - inequality_pressure_proxy)
    ) / 9,
    resilience_inequality_gap = aggregate_resilience_capacity_proxy -
      equality_adjusted_resilience_proxy,
    protection_gap = distributed_protection_index - exposure_concentration_index,
    resilience_band = case_when(
      equality_adjusted_resilience_proxy >= 0.75 ~ "Strong equality-adjusted resilience",
      equality_adjusted_resilience_proxy >= 0.55 ~ "Moderate equality-adjusted resilience",
      equality_adjusted_resilience_proxy >= 0.35 ~ "Limited equality-adjusted resilience",
      TRUE ~ "Weak equality-adjusted resilience"
    )
  )

jurisdiction_summary <- ineq_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_equality_adjusted_resilience = mean(equality_adjusted_resilience_proxy, na.rm = TRUE),
    avg_aggregate_resilience_capacity = mean(aggregate_resilience_capacity_proxy, na.rm = TRUE),
    avg_inequality_pressure = mean(inequality_pressure_proxy, na.rm = TRUE),
    avg_resilience_inequality_gap = mean(resilience_inequality_gap, na.rm = TRUE),
    avg_protection_gap = mean(protection_gap, na.rm = TRUE),
    avg_distributed_protection = mean(distributed_protection_index, na.rm = TRUE),
    avg_household_buffers = mean(household_buffer_index, na.rm = TRUE),
    avg_service_access = mean(service_access_index, na.rm = TRUE),
    avg_institutional_trust = mean(institutional_trust_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_social_protection = mean(social_protection_index, na.rm = TRUE),
    avg_community_voice = mean(community_voice_index, na.rm = TRUE),
    avg_exposure_concentration = mean(exposure_concentration_index, na.rm = TRUE),
    avg_multidimensional_deprivation = mean(multidimensional_deprivation_index, na.rm = TRUE),
    avg_social_exclusion = mean(social_exclusion_index, na.rm = TRUE),
    avg_recovery_inequality = mean(recovery_inequality_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_equality_adjusted_resilience))

place_type_summary <- ineq_df %>%
  group_by(place_type) %>%
  summarise(
    avg_equality_adjusted_resilience = mean(equality_adjusted_resilience_proxy, na.rm = TRUE),
    avg_aggregate_resilience_capacity = mean(aggregate_resilience_capacity_proxy, na.rm = TRUE),
    avg_inequality_pressure = mean(inequality_pressure_proxy, na.rm = TRUE),
    avg_resilience_inequality_gap = mean(resilience_inequality_gap, na.rm = TRUE),
    avg_protection_gap = mean(protection_gap, na.rm = TRUE),
    avg_distributed_protection = mean(distributed_protection_index, na.rm = TRUE),
    avg_household_buffers = mean(household_buffer_index, na.rm = TRUE),
    avg_service_access = mean(service_access_index, na.rm = TRUE),
    avg_institutional_trust = mean(institutional_trust_index, na.rm = TRUE),
    avg_adaptive_capacity = mean(adaptive_capacity_index, na.rm = TRUE),
    avg_social_protection = mean(social_protection_index, na.rm = TRUE),
    avg_community_voice = mean(community_voice_index, na.rm = TRUE),
    avg_exposure_concentration = mean(exposure_concentration_index, na.rm = TRUE),
    avg_multidimensional_deprivation = mean(multidimensional_deprivation_index, na.rm = TRUE),
    avg_social_exclusion = mean(social_exclusion_index, na.rm = TRUE),
    avg_recovery_inequality = mean(recovery_inequality_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_inequality_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(place_type_summary, place_type_output_file)

cat("Inequality resilience jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nInequality resilience place-type summary exported to:", place_type_output_file, "\n")
print(place_type_summary)

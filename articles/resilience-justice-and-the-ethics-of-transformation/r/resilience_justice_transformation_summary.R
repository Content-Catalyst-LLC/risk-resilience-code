library(readr)
library(dplyr)

input_file <- "../data/raw/resilience_justice_transformation_panel.csv"
jurisdiction_output_file <- "../outputs/resilience_justice_jurisdiction_summary.csv"
domain_output_file <- "../outputs/resilience_justice_domain_summary.csv"

justice_df <- read_csv(input_file, show_col_types = FALSE)

required_cols <- c(
  "initiative_name",
  "jurisdiction",
  "transformation_domain",
  "technical_resilience_index",
  "distributive_justice_index",
  "procedural_justice_index",
  "recognition_index",
  "rights_protection_index",
  "institutional_accountability_index",
  "ecological_governance_index",
  "intergenerational_responsibility_index",
  "public_legitimacy_index",
  "data_transparency_index",
  "maladaptation_risk_index",
  "harm_shifting_risk_index",
  "exclusion_risk_index",
  "coercion_risk_index",
  "displacement_risk_index",
  "unequal_burden_index"
)

missing_cols <- setdiff(required_cols, names(justice_df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

index_cols <- names(justice_df)[grepl("_index$", names(justice_df))]

invalid_index_cols <- index_cols[
  vapply(
    justice_df[index_cols],
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

justice_df <- justice_df %>%
  mutate(
    justice_oriented_transformation_proxy = (
      distributive_justice_index +
        procedural_justice_index +
        recognition_index +
        rights_protection_index +
        institutional_accountability_index +
        ecological_governance_index +
        intergenerational_responsibility_index +
        public_legitimacy_index +
        data_transparency_index
    ) / 9,
    ethical_risk_pressure_proxy = (
      maladaptation_risk_index +
        harm_shifting_risk_index +
        exclusion_risk_index +
        coercion_risk_index +
        displacement_risk_index +
        unequal_burden_index
    ) / 6,
    legitimacy_adjusted_transformation_proxy = (
      justice_oriented_transformation_proxy +
        technical_resilience_index +
        public_legitimacy_index +
        data_transparency_index +
        (1 - ethical_risk_pressure_proxy)
    ) / 5,
    resilience_justice_gap = legitimacy_adjusted_transformation_proxy -
      ethical_risk_pressure_proxy,
    technical_justice_gap = technical_resilience_index -
      justice_oriented_transformation_proxy,
    justice_band = case_when(
      legitimacy_adjusted_transformation_proxy >= 0.75 ~ "Strong justice-oriented transformation",
      legitimacy_adjusted_transformation_proxy >= 0.55 ~ "Moderate justice-oriented transformation",
      legitimacy_adjusted_transformation_proxy >= 0.35 ~ "Limited justice-oriented transformation",
      TRUE ~ "Weak justice-oriented transformation"
    )
  )

jurisdiction_summary <- justice_df %>%
  group_by(jurisdiction) %>%
  summarise(
    avg_legitimacy_adjusted_transformation = mean(legitimacy_adjusted_transformation_proxy, na.rm = TRUE),
    avg_justice_oriented_transformation = mean(justice_oriented_transformation_proxy, na.rm = TRUE),
    avg_technical_resilience = mean(technical_resilience_index, na.rm = TRUE),
    avg_ethical_risk_pressure = mean(ethical_risk_pressure_proxy, na.rm = TRUE),
    avg_resilience_justice_gap = mean(resilience_justice_gap, na.rm = TRUE),
    avg_technical_justice_gap = mean(technical_justice_gap, na.rm = TRUE),
    avg_distributive_justice = mean(distributive_justice_index, na.rm = TRUE),
    avg_procedural_justice = mean(procedural_justice_index, na.rm = TRUE),
    avg_recognition = mean(recognition_index, na.rm = TRUE),
    avg_rights_protection = mean(rights_protection_index, na.rm = TRUE),
    avg_institutional_accountability = mean(institutional_accountability_index, na.rm = TRUE),
    avg_ecological_governance = mean(ecological_governance_index, na.rm = TRUE),
    avg_intergenerational_responsibility = mean(intergenerational_responsibility_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_harm_shifting_risk = mean(harm_shifting_risk_index, na.rm = TRUE),
    avg_exclusion_risk = mean(exclusion_risk_index, na.rm = TRUE),
    avg_coercion_risk = mean(coercion_risk_index, na.rm = TRUE),
    avg_displacement_risk = mean(displacement_risk_index, na.rm = TRUE),
    avg_unequal_burden = mean(unequal_burden_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_resilience_justice_gap))

domain_summary <- justice_df %>%
  group_by(transformation_domain) %>%
  summarise(
    avg_legitimacy_adjusted_transformation = mean(legitimacy_adjusted_transformation_proxy, na.rm = TRUE),
    avg_justice_oriented_transformation = mean(justice_oriented_transformation_proxy, na.rm = TRUE),
    avg_technical_resilience = mean(technical_resilience_index, na.rm = TRUE),
    avg_ethical_risk_pressure = mean(ethical_risk_pressure_proxy, na.rm = TRUE),
    avg_resilience_justice_gap = mean(resilience_justice_gap, na.rm = TRUE),
    avg_technical_justice_gap = mean(technical_justice_gap, na.rm = TRUE),
    avg_distributive_justice = mean(distributive_justice_index, na.rm = TRUE),
    avg_procedural_justice = mean(procedural_justice_index, na.rm = TRUE),
    avg_recognition = mean(recognition_index, na.rm = TRUE),
    avg_rights_protection = mean(rights_protection_index, na.rm = TRUE),
    avg_institutional_accountability = mean(institutional_accountability_index, na.rm = TRUE),
    avg_ecological_governance = mean(ecological_governance_index, na.rm = TRUE),
    avg_intergenerational_responsibility = mean(intergenerational_responsibility_index, na.rm = TRUE),
    avg_public_legitimacy = mean(public_legitimacy_index, na.rm = TRUE),
    avg_maladaptation_risk = mean(maladaptation_risk_index, na.rm = TRUE),
    avg_harm_shifting_risk = mean(harm_shifting_risk_index, na.rm = TRUE),
    avg_exclusion_risk = mean(exclusion_risk_index, na.rm = TRUE),
    avg_coercion_risk = mean(coercion_risk_index, na.rm = TRUE),
    avg_displacement_risk = mean(displacement_risk_index, na.rm = TRUE),
    avg_unequal_burden = mean(unequal_burden_index, na.rm = TRUE),
    observations = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_ethical_risk_pressure))

write_csv(jurisdiction_summary, jurisdiction_output_file)
write_csv(domain_summary, domain_output_file)

cat("Justice and transformation jurisdiction summary exported to:", jurisdiction_output_file, "\n")
print(jurisdiction_summary)

cat("\nJustice and transformation domain summary exported to:", domain_output_file, "\n")
print(domain_summary)

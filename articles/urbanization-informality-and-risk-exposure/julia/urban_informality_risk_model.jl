# Conceptual urban informality and risk exposure model

function urban_risk_exposure(
    hazard_intensity,
    spatial_exposure,
    household_vulnerability,
    infrastructure_deficit,
    tenure_insecurity,
    livelihood_precarity,
    service_access,
    adaptive_capacity,
    community_organization,
    institutional_protection
)
    return clamp(
        0.15 * hazard_intensity +
        0.14 * spatial_exposure +
        0.14 * household_vulnerability +
        0.13 * infrastructure_deficit +
        0.12 * tenure_insecurity +
        0.11 * livelihood_precarity -
        0.08 * service_access -
        0.05 * adaptive_capacity -
        0.04 * community_organization -
        0.04 * institutional_protection,
        0.0,
        1.0
    )
end

function inclusive_urban_resilience(
    service_upgrading,
    tenure_security,
    infrastructure_quality,
    community_adaptation,
    livelihood_security,
    distributive_justice
)
    return clamp(
        (service_upgrading +
         tenure_security +
         infrastructure_quality +
         community_adaptation +
         livelihood_security +
         distributive_justice) / 6,
        0.0,
        1.0
    )
end

risk = urban_risk_exposure(0.72, 0.70, 0.66, 0.68, 0.61, 0.64, 0.42, 0.48, 0.58, 0.44)
resilience = inclusive_urban_resilience(0.44, 0.39, 0.40, 0.58, 0.36, 0.46)

println("Example urban risk exposure score: ", round(risk, digits = 3))
println("Example inclusive urban resilience score: ", round(resilience, digits = 3))
println("Example protection gap: ", round(resilience - risk, digits = 3))

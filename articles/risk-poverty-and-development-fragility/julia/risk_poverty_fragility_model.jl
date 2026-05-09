# Conceptual poverty-fragility resilience model
# Article: Risk, Poverty, and Development Fragility

"""
Compute development fragility.

Inputs should be normalized to [0, 1].
"""
function development_fragility(
    risk_exposure,
    multidimensional_poverty,
    institutional_weakness,
    livelihood_precarity,
    service_deficit,
    conflict_pressure,
    climate_stress,
    displacement_pressure
)
    return clamp(
        0.18 * risk_exposure +
        0.17 * multidimensional_poverty +
        0.15 * institutional_weakness +
        0.14 * livelihood_precarity +
        0.13 * service_deficit +
        0.10 * conflict_pressure +
        0.08 * climate_stress +
        0.05 * displacement_pressure,
        0.0,
        1.0
    )
end

"""
Compute resilience sufficiency.

Inputs should be normalized to [0, 1].
"""
function resilience_sufficiency(
    social_protection,
    household_buffers,
    adaptive_capacity,
    service_continuity,
    institutional_trust,
    community_voice
)
    return clamp(
        0.18 * social_protection +
        0.17 * household_buffers +
        0.17 * adaptive_capacity +
        0.16 * service_continuity +
        0.16 * institutional_trust +
        0.16 * community_voice,
        0.0,
        1.0
    )
end

fragility = development_fragility(0.72, 0.68, 0.60, 0.66, 0.64, 0.55, 0.62, 0.50)
resilience = resilience_sufficiency(0.42, 0.38, 0.45, 0.40, 0.43, 0.51)

println("Example development fragility score: ", round(fragility, digits = 3))
println("Example resilience sufficiency score: ", round(resilience, digits = 3))
println("Example poverty-fragility gap: ", round(resilience - fragility, digits = 3))

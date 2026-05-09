# Conceptual future-oriented resilience model
# Article: The Future of Resilience Thinking

"""
Compute future-oriented resilience.

Inputs should be normalized to [0, 1].
"""
function future_resilience(
    systemic_risk_capacity,
    governance_integration,
    justice_transformation,
    regenerative_capacity,
    local_capability,
    technological_accountability,
    planetary_alignment,
    investment_readiness,
    fragmentation_risk,
    maladaptation_risk,
    inequality_risk,
    ecological_overshoot_risk
)
    return clamp(
        0.13 * systemic_risk_capacity +
        0.12 * governance_integration +
        0.11 * justice_transformation +
        0.11 * regenerative_capacity +
        0.09 * local_capability +
        0.09 * technological_accountability +
        0.09 * planetary_alignment +
        0.07 * investment_readiness -
        0.06 * fragmentation_risk -
        0.05 * maladaptation_risk -
        0.04 * inequality_risk -
        0.04 * ecological_overshoot_risk,
        0.0,
        1.0
    )
end

"""
Compute future fragility pressure.

Inputs should be normalized to [0, 1].
"""
function future_fragility_pressure(
    fragmentation_risk,
    maladaptation_risk,
    inequality_risk,
    ecological_overshoot_risk,
    technological_dependency_risk,
    conceptual_vagueness
)
    return clamp(
        0.18 * fragmentation_risk +
        0.18 * maladaptation_risk +
        0.17 * inequality_risk +
        0.17 * ecological_overshoot_risk +
        0.15 * technological_dependency_risk +
        0.15 * conceptual_vagueness,
        0.0,
        1.0
    )
end

resilience = future_resilience(0.72, 0.66, 0.63, 0.61, 0.64, 0.58, 0.60, 0.57, 0.31, 0.28, 0.34, 0.40)
fragility = future_fragility_pressure(0.31, 0.28, 0.34, 0.40, 0.36, 0.25)

println("Example future-oriented resilience score: ", round(resilience, digits = 3))
println("Example future fragility pressure score: ", round(fragility, digits = 3))
println("Example future resilience readiness gap: ", round(resilience - fragility, digits = 3))

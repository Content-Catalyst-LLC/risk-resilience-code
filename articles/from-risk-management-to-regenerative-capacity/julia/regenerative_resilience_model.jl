# Conceptual regenerative resilience model
# Article: From Risk Management to Regenerative Capacity

"""
Compute regenerative resilience.

Inputs should be normalized to [0, 1].
"""
function regenerative_resilience(
    risk_management_capacity,
    ecological_restoration,
    social_capacity,
    institutional_learning,
    justice_orientation,
    long_term_investment,
    depletion_pressure,
    maladaptation_risk,
    extractive_pressure,
    institutional_fatigue
)
    return clamp(
        0.14 * risk_management_capacity +
        0.16 * ecological_restoration +
        0.13 * social_capacity +
        0.13 * institutional_learning +
        0.12 * justice_orientation +
        0.12 * long_term_investment -
        0.08 * depletion_pressure -
        0.05 * maladaptation_risk -
        0.04 * extractive_pressure -
        0.03 * institutional_fatigue,
        0.0,
        1.0
    )
end

example_score = regenerative_resilience(0.72, 0.68, 0.66, 0.70, 0.69, 0.63, 0.38, 0.34, 0.32, 0.29)

println("Example regenerative resilience score: ", round(example_score, digits = 3))

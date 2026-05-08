# Conceptual early warning preparedness model
# Article: Early Warning Systems and Preparedness

"""
Compute early warning effectiveness.

Inputs should be normalized to [0, 1].
"""
function warning_effectiveness(
    risk_knowledge,
    forecast_skill,
    lead_time,
    communication_reach,
    trust_strength,
    preparedness_capacity,
    response_capacity,
    access_barriers
)
    return clamp(
        0.14 * risk_knowledge +
        0.14 * forecast_skill +
        0.13 * lead_time +
        0.13 * communication_reach +
        0.12 * trust_strength +
        0.14 * preparedness_capacity +
        0.12 * response_capacity -
        0.08 * access_barriers,
        0.0,
        1.0
    )
end

example_score = warning_effectiveness(0.74, 0.78, 0.70, 0.68, 0.66, 0.72, 0.69, 0.31)

println("Example early warning effectiveness score: ", round(example_score, digits = 3))

# Conceptual AI resilience model
# Article: Resilience in the Age of AI and Automated Systems

"""
Compute AI resilience capacity.

Inputs should be normalized to [0, 1].
"""
function ai_resilience_capacity(
    model_reliability,
    monitoring_capacity,
    oversight_capacity,
    governance_strength,
    contestability,
    fallback_capacity,
    opacity_risk,
    drift_risk
)
    return clamp(
        0.16 * model_reliability +
        0.15 * monitoring_capacity +
        0.15 * oversight_capacity +
        0.15 * governance_strength +
        0.12 * contestability +
        0.12 * fallback_capacity -
        0.08 * opacity_risk -
        0.07 * drift_risk,
        0.0,
        1.0
    )
end

example_score = ai_resilience_capacity(0.76, 0.70, 0.68, 0.74, 0.66, 0.62, 0.35, 0.28)

println("Example AI resilience capacity score: ", round(example_score, digits = 3))

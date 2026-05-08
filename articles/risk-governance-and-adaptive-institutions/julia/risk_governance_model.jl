# Conceptual risk governance model
# Article: Risk Governance and Adaptive Institutions

"""
Compute adaptive risk governance quality.

Inputs should be normalized to [0, 1].
"""
function risk_governance_quality(
    anticipatory_capacity,
    appraisal_quality,
    coordination_capacity,
    participation_strength,
    legitimacy,
    learning_capacity,
    fragmentation,
    capture_risk
)
    return clamp(
        0.16 * anticipatory_capacity +
        0.15 * appraisal_quality +
        0.16 * coordination_capacity +
        0.14 * participation_strength +
        0.15 * legitimacy +
        0.14 * learning_capacity -
        0.05 * fragmentation -
        0.05 * capture_risk,
        0.0,
        1.0
    )
end

example_score = risk_governance_quality(0.72, 0.76, 0.68, 0.70, 0.66, 0.74, 0.34, 0.28)

println("Example adaptive risk governance score: ", round(example_score, digits = 3))

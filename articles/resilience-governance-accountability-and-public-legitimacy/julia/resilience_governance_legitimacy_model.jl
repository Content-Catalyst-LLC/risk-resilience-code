# Conceptual resilience governance model
# Article: Resilience Governance, Accountability, and Public Legitimacy

"""
Compute legitimate resilience governance quality.

Inputs should be normalized to [0, 1].
"""
function legitimate_resilience_governance(
    adaptive_capacity,
    accountability_capacity,
    public_legitimacy,
    transparency,
    participation_strength,
    coordination_capacity,
    learning_capacity,
    justice_orientation,
    fragmentation,
    trust_erosion
)
    return clamp(
        0.13 * adaptive_capacity +
        0.13 * accountability_capacity +
        0.12 * public_legitimacy +
        0.10 * transparency +
        0.10 * participation_strength +
        0.10 * coordination_capacity +
        0.10 * learning_capacity +
        0.10 * justice_orientation -
        0.06 * fragmentation -
        0.06 * trust_erosion,
        0.0,
        1.0
    )
end

example_score = legitimate_resilience_governance(0.72, 0.70, 0.68, 0.74, 0.66, 0.69, 0.73, 0.67, 0.34, 0.29)

println("Example legitimate resilience governance score: ", round(example_score, digits = 3))

# Conceptual public-institution stress readiness model
# Article: Stress Testing Public Institutions

"""
Compute public-institution stress readiness.

Inputs should be normalized to [0, 1].
"""
function stress_readiness(
    essential_function_clarity,
    capacity_margin,
    dependency_visibility,
    workforce_resilience,
    digital_resilience,
    coordination_capacity,
    equity_protection,
    public_trust,
    overload_pressure,
    hidden_fragility
)
    return clamp(
        0.12 * essential_function_clarity +
        0.12 * capacity_margin +
        0.10 * dependency_visibility +
        0.11 * workforce_resilience +
        0.11 * digital_resilience +
        0.11 * coordination_capacity +
        0.10 * equity_protection +
        0.09 * public_trust -
        0.07 * overload_pressure -
        0.07 * hidden_fragility,
        0.0,
        1.0
    )
end

example_score = stress_readiness(0.76, 0.64, 0.70, 0.68, 0.72, 0.66, 0.69, 0.63, 0.42, 0.36)

println("Example public-institution stress readiness score: ", round(example_score, digits = 3))

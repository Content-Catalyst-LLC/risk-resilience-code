# Conceptual polycrisis and transformative resilience model
# Article: Polycrisis, Systemic Risk, and the Future of Resilience Thinking

"""
Compute polycrisis risk pressure.

Inputs should be normalized to [0, 1].
"""
function polycrisis_pressure(
    crisis_domain_intensity,
    interaction_coupling,
    systemic_vulnerability,
    feedback_amplification,
    threshold_proximity,
    institutional_capacity,
    legitimacy,
    regenerative_capacity
)
    return clamp(
        0.16 * crisis_domain_intensity +
        0.15 * interaction_coupling +
        0.16 * systemic_vulnerability +
        0.14 * feedback_amplification +
        0.13 * threshold_proximity -
        0.10 * institutional_capacity -
        0.08 * legitimacy -
        0.08 * regenerative_capacity,
        0.0,
        1.0
    )
end

"""
Compute transformative resilience.

Inputs should be normalized to [0, 1].
"""
function transformative_resilience(
    adaptive_capacity,
    governance_learning,
    equity,
    ecological_renewal,
    data_auditability,
    maladaptation_risk
)
    return clamp(
        0.20 * adaptive_capacity +
        0.19 * governance_learning +
        0.18 * equity +
        0.18 * ecological_renewal +
        0.15 * data_auditability -
        0.10 * maladaptation_risk,
        0.0,
        1.0
    )
end

pressure = polycrisis_pressure(0.74, 0.68, 0.72, 0.64, 0.60, 0.58, 0.55, 0.50)
resilience = transformative_resilience(0.62, 0.58, 0.64, 0.56, 0.60, 0.31)

println("Example polycrisis pressure score: ", round(pressure, digits = 3))
println("Example transformative resilience score: ", round(resilience, digits = 3))
println("Example readiness gap: ", round(resilience - pressure, digits = 3))

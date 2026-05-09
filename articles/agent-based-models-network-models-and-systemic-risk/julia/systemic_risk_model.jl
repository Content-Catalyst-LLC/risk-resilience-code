# Conceptual agent-network systemic-risk model
# Article: Agent-Based Models, Network Models, and Systemic Risk

"""
Compute systemic-risk pressure.

Inputs should be normalized to [0, 1].
"""
function systemic_risk_pressure(
    hazard_severity,
    exposure,
    vulnerability,
    connectivity,
    behavioral_amplification,
    capacity,
    modularity,
    governance
)
    return clamp(
        0.16 * hazard_severity +
        0.15 * exposure +
        0.16 * vulnerability +
        0.14 * connectivity +
        0.14 * behavioral_amplification -
        0.10 * capacity -
        0.08 * modularity -
        0.07 * governance,
        0.0,
        1.0
    )
end

example_score = systemic_risk_pressure(0.82, 0.70, 0.63, 0.74, 0.58, 0.62, 0.55, 0.60)

println("Example systemic-risk pressure score: ", round(example_score, digits = 3))

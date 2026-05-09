# Conceptual nonlinear shock-propagation model
# Article: Nonlinearity and Shock Propagation

function propagation_pressure(
    shock_intensity,
    threshold_proximity,
    network_centrality,
    coupling_strength,
    feedback_amplification,
    hidden_stress,
    exposure_inequality
)
    return clamp(
        0.16 * shock_intensity +
        0.18 * threshold_proximity +
        0.16 * network_centrality +
        0.16 * coupling_strength +
        0.14 * feedback_amplification +
        0.10 * hidden_stress +
        0.10 * exposure_inequality,
        0.0,
        1.0
    )
end

function containment_capacity(
    buffering_capacity,
    modularity,
    redundancy,
    adaptive_response,
    governance_quality
)
    return clamp(
        0.22 * buffering_capacity +
        0.20 * modularity +
        0.20 * redundancy +
        0.20 * adaptive_response +
        0.18 * governance_quality,
        0.0,
        1.0
    )
end

function nonlinear_damage(shock_intensity, threshold_proximity)
    # Demonstrates nonlinear amplification as threshold proximity approaches 1.
    if threshold_proximity >= 1.0
        return Inf
    end

    return shock_intensity / (1.0 - threshold_proximity)
end

pressure = propagation_pressure(0.56, 0.82, 0.74, 0.78, 0.70, 0.72, 0.68)
capacity = containment_capacity(0.44, 0.46, 0.50, 0.48, 0.52)
risk = clamp(0.74 * pressure - 0.26 * capacity, 0.0, 1.0)
damage = nonlinear_damage(0.56, 0.82)

println("Example propagation pressure score: ", round(pressure, digits = 3))
println("Example containment capacity score: ", round(capacity, digits = 3))
println("Example nonlinear propagation risk score: ", round(risk, digits = 3))
println("Example propagation resilience margin: ", round(capacity - pressure, digits = 3))
println("Example nonlinear damage proxy: ", round(damage, digits = 3))

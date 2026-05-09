# Conceptual planetary boundaries risk model
# Article: Planetary Boundaries and Global System Risk

function planetary_pressure(
    boundary_transgression,
    pressure_trend,
    interaction_strength,
    reversibility_risk,
    human_system_exposure
)
    return clamp(
        0.26 * boundary_transgression +
        0.22 * pressure_trend +
        0.20 * interaction_strength +
        0.18 * reversibility_risk +
        0.14 * human_system_exposure,
        0.0,
        1.0
    )
end

function response_capacity(
    monitoring_confidence,
    adaptive_capacity,
    governance_quality,
    justice_transition,
    policy_response
)
    return clamp(
        0.20 * monitoring_confidence +
        0.22 * adaptive_capacity +
        0.22 * governance_quality +
        0.18 * justice_transition +
        0.18 * policy_response,
        0.0,
        1.0
    )
end

pressure = planetary_pressure(0.86, 0.78, 0.82, 0.74, 0.80)
capacity = response_capacity(0.72, 0.46, 0.42, 0.38, 0.44)
risk = clamp(0.74 * pressure + 0.18 * 0.80 + 0.08 * 0.74 - 0.24 * capacity, 0.0, 1.0)
margin = capacity - pressure

println("Example planetary pressure score: ", round(pressure, digits = 3))
println("Example response capacity score: ", round(capacity, digits = 3))
println("Example planetary system risk score: ", round(risk, digits = 3))
println("Example Earth-system resilience margin: ", round(margin, digits = 3))

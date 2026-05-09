# Conceptual tight-coupling catastrophic-failure model
# Article: Tight Coupling and the Logic of Catastrophic Failure

function tight_coupling_pressure(
    coupling_strength,
    time_compression,
    sequence_rigidity,
    limited_substitution,
    interactive_complexity,
    hidden_dependency,
    critical_node_importance
)
    return clamp(
        0.16 * coupling_strength +
        0.16 * time_compression +
        0.14 * sequence_rigidity +
        0.13 * limited_substitution +
        0.15 * interactive_complexity +
        0.12 * hidden_dependency +
        0.14 * critical_node_importance,
        0.0,
        1.0
    )
end

function resilience_room(
    buffering,
    modularity,
    redundancy,
    adaptive_authority,
    fallback_capacity
)
    return clamp(
        0.22 * buffering +
        0.20 * modularity +
        0.20 * redundancy +
        0.20 * adaptive_authority +
        0.18 * fallback_capacity,
        0.0,
        1.0
    )
end

function time_to_containment_gap(response_time, failure_time)
    return response_time - failure_time
end

pressure = tight_coupling_pressure(0.82, 0.84, 0.78, 0.74, 0.76, 0.70, 0.80)
room = resilience_room(0.42, 0.44, 0.48, 0.46, 0.40)
risk = clamp(0.74 * pressure - 0.26 * room, 0.0, 1.0)
gap = time_to_containment_gap(30.0, 12.0)

println("Example tight-coupling pressure score: ", round(pressure, digits = 3))
println("Example resilience room score: ", round(room, digits = 3))
println("Example catastrophic-failure risk score: ", round(risk, digits = 3))
println("Example containment margin: ", round(room - pressure, digits = 3))
println("Example time-to-containment gap: ", round(gap, digits = 3), " minutes")

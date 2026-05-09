# Conceptual efficiency, slack, and resilience model
# Article: Efficiency, Slack, and Resilience in System Design

function resilience_capacity(
    routine_efficiency,
    protective_slack,
    redundancy,
    modularity,
    diversity,
    feedback_monitoring,
    repair_capacity,
    governance_quality
)
    return clamp(
        0.12 * routine_efficiency +
        0.16 * protective_slack +
        0.14 * redundancy +
        0.13 * modularity +
        0.12 * diversity +
        0.12 * feedback_monitoring +
        0.11 * repair_capacity +
        0.10 * governance_quality,
        0.0,
        1.0
    )
end

function optimization_fragility_pressure(
    tight_coupling,
    single_point_dependence,
    overload,
    deferred_maintenance,
    hidden_risk_transfer
)
    return clamp(
        0.22 * tight_coupling +
        0.22 * single_point_dependence +
        0.20 * overload +
        0.18 * deferred_maintenance +
        0.18 * hidden_risk_transfer,
        0.0,
        1.0
    )
end

capacity = resilience_capacity(0.82, 0.48, 0.52, 0.56, 0.50, 0.58, 0.54, 0.60)
pressure = optimization_fragility_pressure(0.74, 0.70, 0.76, 0.62, 0.68)
performance = clamp(0.70 * capacity - 0.30 * pressure, 0.0, 1.0)

println("Example resilience capacity score: ", round(capacity, digits = 3))
println("Example optimization fragility pressure score: ", round(pressure, digits = 3))
println("Example resilience-aware performance score: ", round(performance, digits = 3))
println("Example slack-fragility gap: ", round(capacity - pressure, digits = 3))

# Conceptual environmental monitoring resilience model

function monitoring_capacity(
    observation_coverage,
    data_quality,
    timeliness,
    interoperability,
    analytical_capacity,
    warning_dissemination,
    community_validation,
    action_linkage,
    rights_safeguards
)
    return clamp(
        0.15 * observation_coverage +
        0.14 * data_quality +
        0.13 * timeliness +
        0.12 * interoperability +
        0.12 * analytical_capacity +
        0.11 * warning_dissemination +
        0.09 * community_validation +
        0.09 * action_linkage +
        0.05 * rights_safeguards,
        0.0,
        1.0
    )
end

function monitoring_risk_pressure(
    blind_spots,
    uncertainty_burden,
    decision_lag,
    maintenance_risk,
    misuse_risk
)
    return clamp(
        0.24 * blind_spots +
        0.20 * uncertainty_burden +
        0.20 * decision_lag +
        0.18 * maintenance_risk +
        0.18 * misuse_risk,
        0.0,
        1.0
    )
end

capacity = monitoring_capacity(0.72, 0.68, 0.70, 0.61, 0.64, 0.66, 0.58, 0.60, 0.62)
pressure = monitoring_risk_pressure(0.34, 0.38, 0.40, 0.36, 0.30)
supported_resilience = clamp(0.72 * capacity + 0.18 * 0.60 + 0.10 * 0.62 - 0.22 * pressure, 0.0, 1.0)

println("Example monitoring capacity score: ", round(capacity, digits = 3))
println("Example monitoring risk pressure score: ", round(pressure, digits = 3))
println("Example monitoring-supported resilience score: ", round(supported_resilience, digits = 3))

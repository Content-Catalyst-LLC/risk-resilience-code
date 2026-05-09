# Conceptual path dependence, lock-in, and resilience traps model
# Article: Path Dependence, Lock-In, and Resilience Traps

function lock_in_pressure(
    sunk_cost,
    infrastructure_rigidity,
    institutional_inertia,
    incumbent_power,
    social_dependence,
    technological_incompatibility,
    ecological_feedback
)
    return clamp(
        0.16 * sunk_cost +
        0.16 * infrastructure_rigidity +
        0.16 * institutional_inertia +
        0.16 * incumbent_power +
        0.14 * social_dependence +
        0.11 * technological_incompatibility +
        0.11 * ecological_feedback,
        0.0,
        1.0
    )
end

function transformation_capacity(
    alternative_capacity,
    adaptive_governance,
    public_legitimacy,
    justice_transition,
    reversibility
)
    return clamp(
        0.22 * alternative_capacity +
        0.22 * adaptive_governance +
        0.18 * public_legitimacy +
        0.20 * justice_transition +
        0.18 * reversibility,
        0.0,
        1.0
    )
end

pressure = lock_in_pressure(0.82, 0.78, 0.74, 0.80, 0.70, 0.66, 0.62)
capacity = transformation_capacity(0.44, 0.48, 0.52, 0.46, 0.38)
trap_risk = clamp(0.72 * pressure - 0.28 * capacity, 0.0, 1.0)
readiness = clamp(0.68 * capacity - 0.32 * pressure, 0.0, 1.0)

println("Example lock-in pressure score: ", round(pressure, digits = 3))
println("Example transformation capacity score: ", round(capacity, digits = 3))
println("Example resilience trap risk score: ", round(trap_risk, digits = 3))
println("Example transformation readiness score: ", round(readiness, digits = 3))
println("Example escape gap: ", round(capacity - pressure, digits = 3))

# Conceptual energy security and grid resilience model
# Article: Energy Security, Grid Fragility, and Resilience

function energy_resilience_capacity(
    reliability,
    adequacy,
    redundancy,
    flexibility,
    distributed_capacity,
    cyber_resilience,
    restoration_capacity,
    critical_load_protection
)
    return clamp(
        0.14 * reliability +
        0.13 * adequacy +
        0.13 * redundancy +
        0.12 * flexibility +
        0.11 * distributed_capacity +
        0.11 * cyber_resilience +
        0.13 * restoration_capacity +
        0.13 * critical_load_protection,
        0.0,
        1.0
    )
end

function grid_fragility_pressure(
    climate_exposure,
    infrastructure_aging,
    fuel_dependence,
    digital_fragility,
    load_growth_pressure,
    interdependency_risk
)
    return clamp(
        0.18 * climate_exposure +
        0.17 * infrastructure_aging +
        0.15 * fuel_dependence +
        0.15 * digital_fragility +
        0.18 * load_growth_pressure +
        0.17 * interdependency_risk,
        0.0,
        1.0
    )
end

function just_energy_resilience(
    affordability,
    equity_protection,
    critical_load_protection,
    distributed_capacity,
    restoration_capacity
)
    return clamp(
        0.24 * affordability +
        0.24 * equity_protection +
        0.22 * critical_load_protection +
        0.16 * distributed_capacity +
        0.14 * restoration_capacity,
        0.0,
        1.0
    )
end

capacity = energy_resilience_capacity(0.72, 0.68, 0.58, 0.62, 0.54, 0.60, 0.66, 0.64)
fragility = grid_fragility_pressure(0.76, 0.64, 0.48, 0.58, 0.70, 0.72)
justice = just_energy_resilience(0.50, 0.46, 0.64, 0.54, 0.66)
overall = clamp(0.58 * capacity + 0.22 * justice - 0.28 * fragility, 0.0, 1.0)

println("Example energy resilience capacity score: ", round(capacity, digits = 3))
println("Example grid fragility pressure score: ", round(fragility, digits = 3))
println("Example just energy resilience score: ", round(justice, digits = 3))
println("Example energy-security resilience score: ", round(overall, digits = 3))
println("Example resilience-fragility gap: ", round(capacity - fragility, digits = 3))

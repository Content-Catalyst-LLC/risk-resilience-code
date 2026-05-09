# Conceptual drinking-water resilience model
# Article: Clean Drinking Water, Desalination, and Water-Supply Resilience

function water_resilience_capacity(
    source_protection,
    treatment_capacity,
    distribution_reliability,
    monitoring_quality,
    supply_diversity,
    energy_resilience,
    affordability,
    governance_capacity
)
    return clamp(
        0.15 * source_protection +
        0.16 * treatment_capacity +
        0.15 * distribution_reliability +
        0.14 * monitoring_quality +
        0.11 * supply_diversity +
        0.10 * energy_resilience +
        0.09 * affordability +
        0.10 * governance_capacity,
        0.0,
        1.0
    )
end

function water_system_risk_pressure(
    contamination_risk,
    infrastructure_aging,
    salinity_pressure,
    energy_dependence,
    brine_burden,
    access_inequality
)
    return clamp(
        0.22 * contamination_risk +
        0.18 * infrastructure_aging +
        0.16 * salinity_pressure +
        0.15 * energy_dependence +
        0.13 * brine_burden +
        0.16 * access_inequality,
        0.0,
        1.0
    )
end

capacity = water_resilience_capacity(0.70, 0.78, 0.62, 0.68, 0.58, 0.56, 0.52, 0.64)
pressure = water_system_risk_pressure(0.46, 0.58, 0.50, 0.62, 0.44, 0.54)
resilience = clamp(0.72 * capacity - 0.28 * pressure, 0.0, 1.0)

println("Example water resilience capacity score: ", round(capacity, digits = 3))
println("Example water-system risk pressure score: ", round(pressure, digits = 3))
println("Example drinking-water resilience score: ", round(resilience, digits = 3))
println("Example source-to-tap resilience gap: ", round(capacity - pressure, digits = 3))

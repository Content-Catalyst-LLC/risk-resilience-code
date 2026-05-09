# Conceptual biodiversity-supported ecological resilience model
# Article: Biodiversity Loss and Ecological Resilience

"""
Compute biodiversity-supported ecological resilience.

Inputs should be normalized to [0, 1].
"""
function biodiversity_resilience(
    genetic_diversity,
    species_diversity,
    functional_diversity,
    habitat_connectivity,
    ecosystem_integrity,
    adaptive_capacity,
    fragmentation_pressure,
    pollution_pressure,
    invasive_pressure,
    extraction_pressure
)
    return clamp(
        0.14 * genetic_diversity +
        0.15 * species_diversity +
        0.16 * functional_diversity +
        0.14 * habitat_connectivity +
        0.14 * ecosystem_integrity +
        0.10 * adaptive_capacity -
        0.07 * fragmentation_pressure -
        0.04 * pollution_pressure -
        0.03 * invasive_pressure -
        0.03 * extraction_pressure,
        0.0,
        1.0
    )
end

"""
Compute ecological pressure.

Inputs should be normalized to [0, 1].
"""
function ecological_pressure(
    fragmentation_pressure,
    pollution_pressure,
    invasive_pressure,
    extraction_pressure,
    climate_stress,
    monitoring_gap
)
    return clamp(
        0.18 * fragmentation_pressure +
        0.16 * pollution_pressure +
        0.16 * invasive_pressure +
        0.18 * extraction_pressure +
        0.20 * climate_stress +
        0.12 * monitoring_gap,
        0.0,
        1.0
    )
end

resilience = biodiversity_resilience(0.70, 0.74, 0.69, 0.63, 0.66, 0.61, 0.34, 0.28, 0.25, 0.31)
pressure = ecological_pressure(0.34, 0.28, 0.25, 0.31, 0.45, 0.22)

println("Example biodiversity-supported resilience score: ", round(resilience, digits = 3))
println("Example ecological pressure score: ", round(pressure, digits = 3))
println("Example ecological resilience gap: ", round(resilience - pressure, digits = 3))

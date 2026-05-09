# Conceptual regenerative resilience model
# Article: Regenerative Resilience and the Repair of Living Systems

"""
Compute regenerative resilience.

Inputs should be normalized to [0, 1].
"""
function regenerative_resilience(
    ecosystem_integrity,
    biodiversity,
    soil_health,
    water_function,
    connectivity,
    local_stewardship,
    governance_accountability,
    justice_repair,
    degradation_pressure,
    fragmentation_pressure,
    extraction_pressure,
    maladaptation_risk
)
    return clamp(
        0.13 * ecosystem_integrity +
        0.12 * biodiversity +
        0.12 * soil_health +
        0.11 * water_function +
        0.10 * connectivity +
        0.09 * local_stewardship +
        0.09 * governance_accountability +
        0.08 * justice_repair -
        0.06 * degradation_pressure -
        0.04 * fragmentation_pressure -
        0.03 * extraction_pressure -
        0.03 * maladaptation_risk,
        0.0,
        1.0
    )
end

"""
Compute restoration integrity.

Inputs should be normalized to [0, 1].
"""
function restoration_integrity(
    functional_recovery,
    biodiversity_recovery,
    hydrological_repair,
    community_stewardship,
    justice_outcome
)
    return (functional_recovery + biodiversity_recovery + hydrological_repair + community_stewardship + justice_outcome) / 5
end

resilience = regenerative_resilience(0.68, 0.70, 0.66, 0.63, 0.61, 0.64, 0.58, 0.55, 0.36, 0.34, 0.30, 0.28)
integrity = restoration_integrity(0.64, 0.61, 0.67, 0.70, 0.58)

println("Example regenerative resilience score: ", round(resilience, digits = 3))
println("Example restoration integrity score: ", round(integrity, digits = 3))
println("Example repair interpretation gap: ", round(resilience - (1 - integrity), digits = 3))

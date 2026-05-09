# Conceptual integrated resilience governance model
# Article: Cross-Sector Coordination and Integrated Resilience Governance

"""
Compute integrated resilience governance capacity.

Inputs should be normalized to [0, 1].
"""
function integrated_governance_capacity(
    cross_sector_coordination,
    dependency_visibility,
    governance_integration,
    data_interoperability,
    public_accountability,
    justice_equity,
    local_capability,
    adaptive_learning,
    fragmentation_risk,
    mandate_conflict,
    data_gap
)
    return clamp(
        0.15 * cross_sector_coordination +
        0.13 * dependency_visibility +
        0.12 * governance_integration +
        0.10 * data_interoperability +
        0.10 * public_accountability +
        0.09 * justice_equity +
        0.08 * local_capability +
        0.08 * adaptive_learning -
        0.06 * fragmentation_risk -
        0.05 * mandate_conflict -
        0.04 * data_gap,
        0.0,
        1.0
    )
end

"""
Compute coordination fragility pressure.

Inputs should be normalized to [0, 1].
"""
function coordination_fragility_pressure(
    fragmentation_risk,
    mandate_conflict,
    governance_data_gap,
    maladaptation_risk,
    private_operator_opacity,
    accountability_diffusion
)
    return clamp(
        0.19 * fragmentation_risk +
        0.17 * mandate_conflict +
        0.17 * governance_data_gap +
        0.16 * maladaptation_risk +
        0.15 * private_operator_opacity +
        0.16 * accountability_diffusion,
        0.0,
        1.0
    )
end

capacity = integrated_governance_capacity(0.70, 0.64, 0.66, 0.61, 0.63, 0.62, 0.68, 0.60, 0.31, 0.28, 0.30)
pressure = coordination_fragility_pressure(0.31, 0.28, 0.30, 0.27, 0.34, 0.32)

println("Example integrated governance capacity score: ", round(capacity, digits = 3))
println("Example coordination fragility pressure score: ", round(pressure, digits = 3))
println("Example integrated resilience governance gap: ", round(capacity - pressure, digits = 3))

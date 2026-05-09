# Conceptual public institutional resilience model
# Article: Public Institutional Resilience Strategy

"""
Compute public institutional resilience.

Inputs should be normalized to [0, 1].
"""
function public_institutional_resilience(
    anticipatory_foresight,
    continuity_operations,
    administrative_capacity,
    coordination_capacity,
    risk_informed_finance,
    procurement_resilience,
    digital_fallback,
    public_legitimacy,
    justice_service_equity,
    learning_adaptation,
    fragmentation_risk,
    underinvestment_risk,
    staffing_fragility,
    digital_dependency_risk,
    accountability_gap
)
    return clamp(
        0.12 * anticipatory_foresight +
        0.12 * continuity_operations +
        0.11 * administrative_capacity +
        0.10 * coordination_capacity +
        0.09 * risk_informed_finance +
        0.09 * procurement_resilience +
        0.07 * digital_fallback +
        0.07 * public_legitimacy +
        0.07 * justice_service_equity +
        0.06 * learning_adaptation -
        0.04 * fragmentation_risk -
        0.04 * underinvestment_risk -
        0.03 * staffing_fragility -
        0.03 * digital_dependency_risk -
        0.02 * accountability_gap,
        0.0,
        1.0
    )
end

"""
Compute institutional fragility pressure.

Inputs should be normalized to [0, 1].
"""
function institutional_fragility_pressure(
    fragmentation_risk,
    underinvestment_risk,
    staffing_fragility,
    digital_dependency_risk,
    procurement_vulnerability,
    accountability_gap
)
    return clamp(
        0.18 * fragmentation_risk +
        0.18 * underinvestment_risk +
        0.17 * staffing_fragility +
        0.16 * digital_dependency_risk +
        0.15 * procurement_vulnerability +
        0.16 * accountability_gap,
        0.0,
        1.0
    )
end

resilience = public_institutional_resilience(
    0.68, 0.72, 0.65, 0.63, 0.60,
    0.58, 0.61, 0.66, 0.64, 0.62,
    0.30, 0.34, 0.32, 0.36, 0.28
)

fragility = institutional_fragility_pressure(0.30, 0.34, 0.32, 0.36, 0.33, 0.28)

println("Example public institutional resilience score: ", round(resilience, digits = 3))
println("Example institutional fragility pressure score: ", round(fragility, digits = 3))
println("Example institutional resilience gap: ", round(resilience - fragility, digits = 3))

# Conceptual inequality-adjusted resilience model
# Article: Why Inequality Weakens Resilience

"""
Compute equality-adjusted resilience.

Inputs should be normalized to [0, 1].
"""
function equality_adjusted_resilience(
    system_capacity,
    distributed_protection,
    household_buffers,
    service_access,
    institutional_trust,
    adaptive_capacity,
    exposure_concentration,
    multidimensional_deprivation,
    social_exclusion,
    recovery_inequality
)
    return clamp(
        0.16 * system_capacity +
        0.16 * distributed_protection +
        0.14 * household_buffers +
        0.14 * service_access +
        0.12 * institutional_trust +
        0.12 * adaptive_capacity -
        0.07 * exposure_concentration -
        0.04 * multidimensional_deprivation -
        0.03 * social_exclusion -
        0.02 * recovery_inequality,
        0.0,
        1.0
    )
end

"""
Compute inequality pressure.

Inputs should be normalized to [0, 1].
"""
function inequality_pressure(
    exposure_concentration,
    multidimensional_deprivation,
    social_exclusion,
    recovery_inequality,
    digital_exclusion,
    fiscal_stress
)
    return clamp(
        0.22 * exposure_concentration +
        0.20 * multidimensional_deprivation +
        0.18 * social_exclusion +
        0.16 * recovery_inequality +
        0.13 * digital_exclusion +
        0.11 * fiscal_stress,
        0.0,
        1.0
    )
end

resilience = equality_adjusted_resilience(0.70, 0.58, 0.52, 0.60, 0.55, 0.57, 0.46, 0.42, 0.38, 0.44)
pressure = inequality_pressure(0.46, 0.42, 0.38, 0.44, 0.36, 0.40)

println("Example equality-adjusted resilience score: ", round(resilience, digits = 3))
println("Example inequality pressure score: ", round(pressure, digits = 3))
println("Example resilience-pressure gap: ", round(resilience - pressure, digits = 3))

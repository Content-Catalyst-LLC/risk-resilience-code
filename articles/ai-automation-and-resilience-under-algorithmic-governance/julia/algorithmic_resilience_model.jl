# Conceptual algorithmic resilience model
# Article: AI, Automation, and Resilience Under Algorithmic Governance

"""
Compute algorithmic resilience.

Inputs should be normalized to [0, 1].
"""
function algorithmic_resilience(
    model_capability,
    institutional_governance,
    data_quality,
    human_oversight,
    system_robustness,
    auditability,
    opacity,
    bias_severity,
    model_drift,
    automation_dependency,
    cyber_exposure
)
    return clamp(
        0.13 * model_capability +
        0.13 * institutional_governance +
        0.11 * data_quality +
        0.12 * human_oversight +
        0.11 * system_robustness +
        0.10 * auditability -
        0.08 * opacity -
        0.07 * bias_severity -
        0.06 * model_drift -
        0.05 * automation_dependency -
        0.04 * cyber_exposure,
        0.0,
        1.0
    )
end

"""
Compute automation fragility.

Inputs should be normalized to [0, 1].
"""
function automation_fragility(
    automation_dependency,
    vendor_concentration,
    model_drift,
    process_opacity,
    cyber_common_mode_dependency,
    fallback_capacity
)
    return clamp(
        0.22 * automation_dependency +
        0.20 * vendor_concentration +
        0.18 * model_drift +
        0.16 * process_opacity +
        0.14 * cyber_common_mode_dependency -
        0.10 * fallback_capacity,
        0.0,
        1.0
    )
end

resilience = algorithmic_resilience(0.74, 0.66, 0.70, 0.63, 0.68, 0.62, 0.31, 0.28, 0.34, 0.40, 0.36)
fragility = automation_fragility(0.40, 0.46, 0.34, 0.31, 0.36, 0.52)

println("Example algorithmic resilience score: ", round(resilience, digits = 3))
println("Example automation fragility score: ", round(fragility, digits = 3))
println("Example resilience gap: ", round(resilience - fragility, digits = 3))

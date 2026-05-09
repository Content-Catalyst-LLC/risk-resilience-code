# Conceptual justice-oriented transformation model
# Article: Resilience, Justice, and the Ethics of Transformation

"""
Compute justice-oriented transformation.

Inputs should be normalized to [0, 1].
"""
function justice_oriented_transformation(
    distributive_justice,
    procedural_justice,
    recognition,
    rights_protection,
    institutional_accountability,
    ecological_governance,
    intergenerational_responsibility,
    maladaptation,
    harm_shifting,
    exclusion,
    coercion
)
    return clamp(
        0.15 * distributive_justice +
        0.14 * procedural_justice +
        0.12 * recognition +
        0.12 * rights_protection +
        0.11 * institutional_accountability +
        0.10 * ecological_governance +
        0.09 * intergenerational_responsibility -
        0.08 * maladaptation -
        0.05 * harm_shifting -
        0.03 * exclusion -
        0.01 * coercion,
        0.0,
        1.0
    )
end

"""
Compute ethical risk pressure.

Inputs should be normalized to [0, 1].
"""
function ethical_risk_pressure(
    maladaptation,
    harm_shifting,
    exclusion,
    coercion,
    displacement,
    unequal_burden
)
    return clamp(
        0.20 * maladaptation +
        0.18 * harm_shifting +
        0.17 * exclusion +
        0.15 * coercion +
        0.15 * displacement +
        0.15 * unequal_burden,
        0.0,
        1.0
    )
end

justice_score = justice_oriented_transformation(0.68, 0.64, 0.61, 0.66, 0.62, 0.58, 0.60, 0.30, 0.28, 0.25, 0.22)
risk_score = ethical_risk_pressure(0.30, 0.28, 0.25, 0.22, 0.34, 0.31)

println("Example justice-oriented transformation score: ", round(justice_score, digits = 3))
println("Example ethical risk pressure score: ", round(risk_score, digits = 3))
println("Example resilience justice gap: ", round(justice_score - risk_score, digits = 3))

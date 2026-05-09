# Conceptual resilience data trust model
# Article: Resilience Data, Provenance, and Auditability

"""
Compute resilience-data trust.

Inputs should be normalized to [0, 1].
"""
function resilience_data_trust(
    provenance_completeness,
    metadata_quality,
    lineage_clarity,
    auditability,
    reproducibility,
    data_quality,
    ethical_governance,
    missingness_gap,
    opacity,
    undocumented_transformation,
    security_privacy_risk
)
    return clamp(
        0.13 * provenance_completeness +
        0.11 * metadata_quality +
        0.11 * lineage_clarity +
        0.13 * auditability +
        0.10 * reproducibility +
        0.12 * data_quality +
        0.12 * ethical_governance -
        0.07 * missingness_gap -
        0.05 * opacity -
        0.04 * undocumented_transformation -
        0.02 * security_privacy_risk,
        0.0,
        1.0
    )
end

example_score = resilience_data_trust(0.78, 0.74, 0.71, 0.68, 0.65, 0.72, 0.70, 0.24, 0.28, 0.22, 0.18)

println("Example resilience-data trust score: ", round(example_score, digits = 3))

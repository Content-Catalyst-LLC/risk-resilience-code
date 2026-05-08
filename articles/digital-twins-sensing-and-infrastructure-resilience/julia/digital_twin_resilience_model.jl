# Conceptual digital twin resilience model
# Article: Digital Twins, Sensing, and Infrastructure Resilience

"""
Compute digital twin resilience contribution.

Inputs should be normalized to [0, 1].
"""
function digital_twin_resilience(
    sensing_coverage,
    data_quality,
    model_validity,
    decision_integration,
    governance_capacity,
    cyber_risk,
    model_uncertainty
)
    return clamp(
        0.18 * sensing_coverage +
        0.18 * data_quality +
        0.18 * model_validity +
        0.18 * decision_integration +
        0.16 * governance_capacity -
        0.07 * cyber_risk -
        0.05 * model_uncertainty,
        0.0,
        1.0
    )
end

example_score = digital_twin_resilience(0.78, 0.72, 0.68, 0.70, 0.74, 0.35, 0.30)

println("Example digital twin resilience score: ", round(example_score, digits = 3))

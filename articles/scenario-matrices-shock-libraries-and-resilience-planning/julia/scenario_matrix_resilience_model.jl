# Conceptual scenario matrix and shock-library resilience planning model
# Article: Scenario Matrices, Shock Libraries, and Resilience Planning

"""
Compute scenario-based resilience planning readiness.

Inputs should be normalized to [0, 1].
"""
function scenario_resilience_planning(
    scenario_coverage,
    shock_library_quality,
    shock_specificity,
    compound_risk_coverage,
    trigger_readiness,
    equity_integration,
    action_linkage,
    adaptive_decision_capacity,
    blind_spot_gap,
    scenario_theater_risk
)
    return clamp(
        0.12 * scenario_coverage +
        0.12 * shock_library_quality +
        0.10 * shock_specificity +
        0.10 * compound_risk_coverage +
        0.12 * trigger_readiness +
        0.10 * equity_integration +
        0.12 * action_linkage +
        0.12 * adaptive_decision_capacity -
        0.06 * blind_spot_gap -
        0.04 * scenario_theater_risk,
        0.0,
        1.0
    )
end

example_score = scenario_resilience_planning(0.74, 0.70, 0.68, 0.66, 0.64, 0.62, 0.69, 0.65, 0.31, 0.28)

println("Example scenario-based resilience planning readiness score: ", round(example_score, digits = 3))

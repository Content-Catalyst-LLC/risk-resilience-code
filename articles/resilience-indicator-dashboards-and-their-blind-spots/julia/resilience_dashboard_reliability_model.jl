# Conceptual resilience dashboard reliability model
# Article: Resilience Indicator Dashboards and Their Blind Spots

"""
Compute equity-adjusted dashboard reliability.

Inputs should be normalized to [0, 1].
"""
function dashboard_reliability(
    indicator_coverage,
    data_quality,
    disaggregation_strength,
    equity_visibility,
    uncertainty_transparency,
    action_linkage,
    community_validation,
    false_precision_risk,
    proxy_dependence,
    aggregation_loss
)
    return clamp(
        0.12 * indicator_coverage +
        0.12 * data_quality +
        0.12 * disaggregation_strength +
        0.12 * equity_visibility +
        0.12 * uncertainty_transparency +
        0.12 * action_linkage +
        0.10 * community_validation -
        0.08 * false_precision_risk -
        0.05 * proxy_dependence -
        0.05 * aggregation_loss,
        0.0,
        1.0
    )
end

example_score = dashboard_reliability(0.74, 0.68, 0.66, 0.63, 0.61, 0.70, 0.58, 0.34, 0.39, 0.42)

println("Example equity-adjusted dashboard reliability score: ", round(example_score, digits = 3))

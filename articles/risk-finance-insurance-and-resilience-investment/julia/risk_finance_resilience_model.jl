# Conceptual risk finance and resilience investment model
# Article: Risk Finance, Insurance, and Resilience Investment

"""
Compute resilience-oriented risk finance capacity.

Inputs should be normalized to [0, 1].
"""
function resilience_finance_capacity(
    risk_visibility,
    insurance_coverage,
    prearranged_finance,
    fiscal_capacity,
    resilience_investment,
    mitigation_incentive,
    equity_protection,
    protection_gap,
    debt_stress,
    hidden_exposure
)
    return clamp(
        0.13 * risk_visibility +
        0.12 * insurance_coverage +
        0.12 * prearranged_finance +
        0.11 * fiscal_capacity +
        0.13 * resilience_investment +
        0.10 * mitigation_incentive +
        0.10 * equity_protection -
        0.07 * protection_gap -
        0.06 * debt_stress -
        0.06 * hidden_exposure,
        0.0,
        1.0
    )
end

example_score = resilience_finance_capacity(0.72, 0.64, 0.68, 0.61, 0.70, 0.66, 0.62, 0.44, 0.38, 0.35)

println("Example resilience finance capacity score: ", round(example_score, digits = 3))

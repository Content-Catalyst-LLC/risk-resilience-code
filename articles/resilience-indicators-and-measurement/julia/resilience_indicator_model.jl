# Conceptual resilience indicator model
# Article: Resilience Indicators and Measurement

"""
Compute measured resilience from normalized indicator families.
Inputs should be normalized to [0, 1].
"""
function measured_resilience(
    capacity,
    assets,
    process,
    outcomes,
    equity_protection,
    financial_protection,
    vulnerability,
    exposure,
    measurement_uncertainty
)
    return clamp(
        0.14 * capacity +
        0.13 * assets +
        0.13 * process +
        0.16 * outcomes +
        0.14 * equity_protection +
        0.10 * financial_protection -
        0.08 * vulnerability -
        0.07 * exposure -
        0.05 * measurement_uncertainty,
        0.0,
        1.0
    )
end

example_score = measured_resilience(0.72, 0.68, 0.70, 0.66, 0.64, 0.61, 0.38, 0.42, 0.24)

println("Example measured resilience score: ", round(example_score, digits = 3))

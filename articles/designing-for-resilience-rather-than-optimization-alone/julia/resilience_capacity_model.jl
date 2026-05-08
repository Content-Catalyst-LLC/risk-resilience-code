function resilience_capacity(
    backup_capacity,
    modularity,
    governance_quality,
    dependency_information,
    equity_protection
)
    return (
        0.22 * backup_capacity +
        0.20 * modularity +
        0.22 * governance_quality +
        0.20 * dependency_information +
        0.16 * equity_protection
    )
end

example_score = resilience_capacity(0.70, 0.65, 0.80, 0.60, 0.75)

println("Example resilience capacity score: ", round(example_score, digits = 3))

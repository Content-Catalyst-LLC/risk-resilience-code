#[derive(Debug)]
struct FutureResilienceStatus {
    name: String,
    systemic_risk_capacity: f64,
    governance_integration: f64,
    justice_transformation: f64,
    regenerative_capacity: f64,
    local_capability: f64,
    technological_accountability: f64,
    planetary_alignment: f64,
    investment_readiness: f64,
    fragmentation_risk: f64,
    maladaptation_risk: f64,
    inequality_risk: f64,
    ecological_overshoot_risk: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn future_resilience(status: &FutureResilienceStatus) -> f64 {
    clamp_01(
        0.13 * status.systemic_risk_capacity
            + 0.12 * status.governance_integration
            + 0.11 * status.justice_transformation
            + 0.11 * status.regenerative_capacity
            + 0.09 * status.local_capability
            + 0.09 * status.technological_accountability
            + 0.09 * status.planetary_alignment
            + 0.07 * status.investment_readiness
            - 0.06 * status.fragmentation_risk
            - 0.05 * status.maladaptation_risk
            - 0.04 * status.inequality_risk
            - 0.04 * status.ecological_overshoot_risk,
    )
}

fn readiness_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong future-oriented resilience framework"
    } else if score >= 0.60 {
        "Moderate future-oriented resilience framework"
    } else if score >= 0.40 {
        "Limited future-oriented resilience framework"
    } else {
        "Weak future-oriented resilience framework"
    }
}

fn main() {
    let status = FutureResilienceStatus {
        name: "Future resilience strategy".to_string(),
        systemic_risk_capacity: 0.72,
        governance_integration: 0.66,
        justice_transformation: 0.63,
        regenerative_capacity: 0.61,
        local_capability: 0.64,
        technological_accountability: 0.58,
        planetary_alignment: 0.60,
        investment_readiness: 0.57,
        fragmentation_risk: 0.31,
        maladaptation_risk: 0.28,
        inequality_risk: 0.34,
        ecological_overshoot_risk: 0.40,
    };

    let score = future_resilience(&status);

    println!("Strategy: {}", status.name);
    println!("Future-oriented resilience score: {:.3}", score);
    println!("Readiness band: {}", readiness_band(score));
}

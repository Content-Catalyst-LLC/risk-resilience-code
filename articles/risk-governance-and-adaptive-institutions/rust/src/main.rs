#[derive(Debug)]
struct GovernanceStatus {
    name: String,
    risk_governance_quality: f64,
    adaptive_capacity: f64,
    governance_vulnerability: f64,
    justice_orientation: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_governance_score(status: &GovernanceStatus) -> f64 {
    clamp_01(
        0.40 * status.risk_governance_quality
            + 0.32 * status.adaptive_capacity
            + 0.18 * (1.0 - status.governance_vulnerability)
            + 0.10 * status.justice_orientation,
    )
}

fn governance_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong adaptive risk governance"
    } else if score >= 0.60 {
        "Moderate adaptive risk governance"
    } else if score >= 0.40 {
        "Limited adaptive risk governance"
    } else {
        "Weak adaptive risk governance"
    }
}

fn main() {
    let status = GovernanceStatus {
        name: "Public Health Risk Governance System".to_string(),
        risk_governance_quality: 0.73,
        adaptive_capacity: 0.68,
        governance_vulnerability: 0.36,
        justice_orientation: 0.71,
    };

    let score = resilience_governance_score(&status);

    println!("Institution/system: {}", status.name);
    println!("Resilience governance score: {:.3}", score);
    println!("Governance band: {}", governance_band(score));
}

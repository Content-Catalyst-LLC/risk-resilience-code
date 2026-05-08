#[derive(Debug)]
struct GovernanceStatus {
    name: String,
    resilience_governance_quality: f64,
    accountability_legitimacy_capacity: f64,
    governance_vulnerability: f64,
    justice_orientation: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn legitimate_resilience_governance_score(status: &GovernanceStatus) -> f64 {
    clamp_01(
        0.38 * status.resilience_governance_quality
            + 0.32 * status.accountability_legitimacy_capacity
            + 0.18 * (1.0 - status.governance_vulnerability)
            + 0.12 * status.justice_orientation,
    )
}

fn governance_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong legitimate resilience governance"
    } else if score >= 0.60 {
        "Moderate legitimate resilience governance"
    } else if score >= 0.40 {
        "Limited legitimate resilience governance"
    } else {
        "Weak legitimate resilience governance"
    }
}

fn main() {
    let status = GovernanceStatus {
        name: "Public Infrastructure Accountability System".to_string(),
        resilience_governance_quality: 0.74,
        accountability_legitimacy_capacity: 0.69,
        governance_vulnerability: 0.35,
        justice_orientation: 0.71,
    };

    let score = legitimate_resilience_governance_score(&status);

    println!("Institution/system: {}", status.name);
    println!("Legitimate resilience governance score: {:.3}", score);
    println!("Governance band: {}", governance_band(score));
}

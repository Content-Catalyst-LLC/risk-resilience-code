#[derive(Debug)]
struct InstitutionStatus {
    name: String,
    stress_readiness: f64,
    stress_vulnerability: f64,
    institutional_recovery: f64,
    equity_protection: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_adjusted_stress_risk(status: &InstitutionStatus) -> f64 {
    clamp_01(
        0.36 * status.stress_vulnerability
            + 0.24 * (1.0 - status.stress_readiness)
            + 0.18 * (1.0 - status.institutional_recovery)
            + 0.22 * (1.0 - status.equity_protection),
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme public-institution stress risk"
    } else if score >= 0.60 {
        "High public-institution stress risk"
    } else if score >= 0.40 {
        "Moderate public-institution stress risk"
    } else {
        "Lower public-institution stress risk"
    }
}

fn main() {
    let status = InstitutionStatus {
        name: "Municipal Emergency Services System".to_string(),
        stress_readiness: 0.70,
        stress_vulnerability: 0.44,
        institutional_recovery: 0.65,
        equity_protection: 0.61,
    };

    let score = resilience_adjusted_stress_risk(&status);

    println!("Institution/system: {}", status.name);
    println!("Resilience-adjusted stress risk: {:.3}", score);
    println!("Risk band: {}", risk_band(score));
}

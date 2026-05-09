#[derive(Debug)]
struct SystemicRiskStatus {
    name: String,
    hazard_severity: f64,
    exposure: f64,
    vulnerability: f64,
    connectivity: f64,
    behavioral_amplification: f64,
    capacity: f64,
    modularity: f64,
    governance: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn systemic_risk_pressure(status: &SystemicRiskStatus) -> f64 {
    clamp_01(
        0.16 * status.hazard_severity
            + 0.15 * status.exposure
            + 0.16 * status.vulnerability
            + 0.14 * status.connectivity
            + 0.14 * status.behavioral_amplification
            - 0.10 * status.capacity
            - 0.08 * status.modularity
            - 0.07 * status.governance,
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme systemic-risk pressure"
    } else if score >= 0.60 {
        "High systemic-risk pressure"
    } else if score >= 0.40 {
        "Moderate systemic-risk pressure"
    } else {
        "Lower systemic-risk pressure"
    }
}

fn main() {
    let status = SystemicRiskStatus {
        name: "Agent-network systemic-risk system".to_string(),
        hazard_severity: 0.82,
        exposure: 0.70,
        vulnerability: 0.63,
        connectivity: 0.74,
        behavioral_amplification: 0.58,
        capacity: 0.62,
        modularity: 0.55,
        governance: 0.60,
    };

    let score = systemic_risk_pressure(&status);

    println!("System: {}", status.name);
    println!("Systemic-risk pressure: {:.3}", score);
    println!("Risk band: {}", risk_band(score));
}

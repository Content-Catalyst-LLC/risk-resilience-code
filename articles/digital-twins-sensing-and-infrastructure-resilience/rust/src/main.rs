#[derive(Debug)]
struct TwinStatus {
    name: String,
    resilience_contribution: f64,
    implementation_risk: f64,
    service_continuity: f64,
    governance_capacity: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_readiness(twin: &TwinStatus) -> f64 {
    clamp_01(
        0.42 * twin.resilience_contribution
            + 0.22 * (1.0 - twin.implementation_risk)
            + 0.18 * twin.service_continuity
            + 0.18 * twin.governance_capacity,
    )
}

fn readiness_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong digital twin resilience readiness"
    } else if score >= 0.60 {
        "Moderate digital twin resilience readiness"
    } else if score >= 0.40 {
        "Limited digital twin resilience readiness"
    } else {
        "Weak digital twin resilience readiness"
    }
}

fn main() {
    let twin = TwinStatus {
        name: "Regional Mobility Twin".to_string(),
        resilience_contribution: 0.70,
        implementation_risk: 0.34,
        service_continuity: 0.86,
        governance_capacity: 0.66,
    };

    let score = resilience_readiness(&twin);

    println!("Digital twin: {}", twin.name);
    println!("Resilience readiness: {:.3}", score);
    println!("Readiness band: {}", readiness_band(score));
}

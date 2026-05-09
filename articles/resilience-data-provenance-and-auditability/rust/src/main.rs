#[derive(Debug)]
struct DataTrustStatus {
    name: String,
    provenance_strength: f64,
    auditability_strength: f64,
    ethical_governance: f64,
    data_quality: f64,
    data_risk_pressure: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_data_trust(status: &DataTrustStatus) -> f64 {
    clamp_01(
        0.30 * status.provenance_strength
            + 0.26 * status.auditability_strength
            + 0.20 * status.ethical_governance
            + 0.14 * status.data_quality
            + 0.10 * (1.0 - status.data_risk_pressure),
    )
}

fn trust_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong resilience data trust"
    } else if score >= 0.60 {
        "Moderate resilience data trust"
    } else if score >= 0.40 {
        "Limited resilience data trust"
    } else {
        "Weak resilience data trust"
    }
}

fn main() {
    let status = DataTrustStatus {
        name: "Resilience indicator evidence chain".to_string(),
        provenance_strength: 0.72,
        auditability_strength: 0.68,
        ethical_governance: 0.70,
        data_quality: 0.74,
        data_risk_pressure: 0.29,
    };

    let score = resilience_data_trust(&status);

    println!("Dataset: {}", status.name);
    println!("Resilience data trust score: {:.3}", score);
    println!("Trust band: {}", trust_band(score));
}

#[derive(Debug)]
struct RegenerativeStatus {
    name: String,
    defensive_risk_management: f64,
    regenerative_capacity: f64,
    depletion_maladaptation_pressure: f64,
    justice_orientation: f64,
    ecological_function: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn regenerative_resilience_score(status: &RegenerativeStatus) -> f64 {
    clamp_01(
        0.34 * status.regenerative_capacity
            + 0.24 * status.defensive_risk_management
            + 0.18 * (1.0 - status.depletion_maladaptation_pressure)
            + 0.12 * status.justice_orientation
            + 0.12 * status.ecological_function,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong regenerative resilience"
    } else if score >= 0.60 {
        "Moderate regenerative resilience"
    } else if score >= 0.40 {
        "Limited regenerative resilience"
    } else {
        "Weak regenerative resilience"
    }
}

fn main() {
    let status = RegenerativeStatus {
        name: "Community Agroecology and Watershed Restoration System".to_string(),
        defensive_risk_management: 0.69,
        regenerative_capacity: 0.67,
        depletion_maladaptation_pressure: 0.37,
        justice_orientation: 0.70,
        ecological_function: 0.65,
    };

    let score = regenerative_resilience_score(&status);

    println!("System: {}", status.name);
    println!("Regenerative resilience score: {:.3}", score);
    println!("Resilience band: {}", resilience_band(score));
}

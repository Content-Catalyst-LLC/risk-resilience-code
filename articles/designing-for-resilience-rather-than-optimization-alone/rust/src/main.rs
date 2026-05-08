#[derive(Debug)]
struct SystemStatus {
    name: String,
    optimization_fragility: f64,
    resilience_capacity: f64,
    service_criticality: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_adjusted_risk(system: &SystemStatus) -> f64 {
    clamp_01(
        0.45 * system.optimization_fragility
            + 0.35 * (1.0 - system.resilience_capacity)
            + 0.20 * system.service_criticality,
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme resilience-design risk"
    } else if score >= 0.60 {
        "High resilience-design risk"
    } else if score >= 0.40 {
        "Moderate resilience-design risk"
    } else {
        "Lower resilience-design risk"
    }
}

fn main() {
    let system = SystemStatus {
        name: "Regional Power Grid".to_string(),
        optimization_fragility: 0.68,
        resilience_capacity: 0.52,
        service_criticality: 0.97,
    };

    let score = resilience_adjusted_risk(&system);

    println!("System: {}", system.name);
    println!("Resilience-adjusted risk: {:.3}", score);
    println!("Risk band: {}", risk_band(score));
}

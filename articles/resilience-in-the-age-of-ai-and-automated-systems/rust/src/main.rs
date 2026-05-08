#[derive(Debug)]
struct AIStatus {
    name: String,
    resilience_capacity: f64,
    automation_fragility: f64,
    service_criticality: f64,
    public_accountability: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_adjusted_risk(system: &AIStatus) -> f64 {
    clamp_01(
        0.36 * system.automation_fragility
            + 0.22 * (1.0 - system.resilience_capacity)
            + 0.22 * system.service_criticality
            + 0.20 * (1.0 - system.public_accountability),
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme AI resilience risk"
    } else if score >= 0.60 {
        "High AI resilience risk"
    } else if score >= 0.40 {
        "Moderate AI resilience risk"
    } else {
        "Lower AI resilience risk"
    }
}

fn main() {
    let system = AIStatus {
        name: "Financial Stress Monitoring Model".to_string(),
        resilience_capacity: 0.68,
        automation_fragility: 0.49,
        service_criticality: 0.91,
        public_accountability: 0.61,
    };

    let score = resilience_adjusted_risk(&system);

    println!("AI system: {}", system.name);
    println!("Resilience-adjusted AI risk: {:.3}", score);
    println!("Risk band: {}", risk_band(score));
}

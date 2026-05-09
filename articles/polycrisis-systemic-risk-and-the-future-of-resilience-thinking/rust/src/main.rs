#[derive(Debug)]
struct PolycrisisStatus {
    name: String,
    crisis_intensity: f64,
    interaction_coupling: f64,
    systemic_vulnerability: f64,
    feedback_amplification: f64,
    threshold_proximity: f64,
    institutional_capacity: f64,
    public_legitimacy: f64,
    regenerative_capacity: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn polycrisis_pressure(status: &PolycrisisStatus) -> f64 {
    clamp_01(
        0.16 * status.crisis_intensity
            + 0.15 * status.interaction_coupling
            + 0.16 * status.systemic_vulnerability
            + 0.14 * status.feedback_amplification
            + 0.13 * status.threshold_proximity
            - 0.10 * status.institutional_capacity
            - 0.08 * status.public_legitimacy
            - 0.08 * status.regenerative_capacity,
    )
}

fn pressure_band(score: f64) -> &'static str {
    if score >= 0.75 {
        "Severe polycrisis pressure"
    } else if score >= 0.55 {
        "High polycrisis pressure"
    } else if score >= 0.35 {
        "Moderate polycrisis pressure"
    } else {
        "Lower polycrisis pressure"
    }
}

fn main() {
    let status = PolycrisisStatus {
        name: "Polycrisis resilience readiness system".to_string(),
        crisis_intensity: 0.74,
        interaction_coupling: 0.68,
        systemic_vulnerability: 0.72,
        feedback_amplification: 0.64,
        threshold_proximity: 0.60,
        institutional_capacity: 0.58,
        public_legitimacy: 0.55,
        regenerative_capacity: 0.50,
    };

    let score = polycrisis_pressure(&status);

    println!("System: {}", status.name);
    println!("Polycrisis pressure: {:.3}", score);
    println!("Pressure band: {}", pressure_band(score));
}

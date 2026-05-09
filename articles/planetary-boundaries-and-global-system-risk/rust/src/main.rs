#[derive(Debug)]
struct BoundaryStatus {
    name: String,
    boundary_transgression: f64,
    pressure_trend: f64,
    interaction_strength: f64,
    reversibility_risk: f64,
    human_system_exposure: f64,
    monitoring_confidence: f64,
    adaptive_capacity: f64,
    governance_quality: f64,
    justice_transition: f64,
    policy_response: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn planetary_pressure(status: &BoundaryStatus) -> f64 {
    clamp_01(
        0.26 * status.boundary_transgression
            + 0.22 * status.pressure_trend
            + 0.20 * status.interaction_strength
            + 0.18 * status.reversibility_risk
            + 0.14 * status.human_system_exposure,
    )
}

fn response_capacity(status: &BoundaryStatus) -> f64 {
    clamp_01(
        0.20 * status.monitoring_confidence
            + 0.22 * status.adaptive_capacity
            + 0.22 * status.governance_quality
            + 0.18 * status.justice_transition
            + 0.18 * status.policy_response,
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Severe planetary system risk"
    } else if score >= 0.60 {
        "High planetary system risk"
    } else if score >= 0.40 {
        "Moderate planetary system risk"
    } else {
        "Lower planetary system risk"
    }
}

fn main() {
    let status = BoundaryStatus {
        name: "Climate change".to_string(),
        boundary_transgression: 0.90,
        pressure_trend: 0.88,
        interaction_strength: 0.86,
        reversibility_risk: 0.82,
        human_system_exposure: 0.92,
        monitoring_confidence: 0.78,
        adaptive_capacity: 0.48,
        governance_quality: 0.44,
        justice_transition: 0.40,
        policy_response: 0.46,
    };

    let pressure = planetary_pressure(&status);
    let capacity = response_capacity(&status);
    let risk = clamp_01(
        0.74 * pressure
            + 0.18 * status.human_system_exposure
            + 0.08 * status.reversibility_risk
            - 0.24 * capacity,
    );

    println!("Boundary: {}", status.name);
    println!("Planetary pressure score: {:.3}", pressure);
    println!("Response capacity score: {:.3}", capacity);
    println!("Planetary system risk score: {:.3}", risk);
    println!("Earth-system resilience margin: {:.3}", capacity - pressure);
    println!("Risk band: {}", risk_band(risk));
}

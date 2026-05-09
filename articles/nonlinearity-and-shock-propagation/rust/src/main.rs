#[derive(Debug)]
struct ShockPropagationStatus {
    name: String,
    shock_intensity: f64,
    threshold_proximity: f64,
    network_centrality: f64,
    coupling_strength: f64,
    feedback_amplification: f64,
    hidden_stress: f64,
    exposure_inequality: f64,
    buffering_capacity: f64,
    modularity: f64,
    redundancy: f64,
    adaptive_response: f64,
    governance_quality: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn propagation_pressure(status: &ShockPropagationStatus) -> f64 {
    clamp_01(
        0.16 * status.shock_intensity
            + 0.18 * status.threshold_proximity
            + 0.16 * status.network_centrality
            + 0.16 * status.coupling_strength
            + 0.14 * status.feedback_amplification
            + 0.10 * status.hidden_stress
            + 0.10 * status.exposure_inequality,
    )
}

fn containment_capacity(status: &ShockPropagationStatus) -> f64 {
    clamp_01(
        0.22 * status.buffering_capacity
            + 0.20 * status.modularity
            + 0.20 * status.redundancy
            + 0.20 * status.adaptive_response
            + 0.18 * status.governance_quality,
    )
}

fn nonlinear_damage(shock_intensity: f64, threshold_proximity: f64) -> f64 {
    if threshold_proximity >= 1.0 {
        return f64::INFINITY;
    }

    shock_intensity / (1.0 - threshold_proximity)
}

fn propagation_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Severe nonlinear propagation risk"
    } else if score >= 0.60 {
        "High nonlinear propagation risk"
    } else if score >= 0.40 {
        "Moderate nonlinear propagation risk"
    } else {
        "Lower nonlinear propagation risk"
    }
}

fn main() {
    let status = ShockPropagationStatus {
        name: "Climate-health-infrastructure cascade".to_string(),
        shock_intensity: 0.62,
        threshold_proximity: 0.84,
        network_centrality: 0.74,
        coupling_strength: 0.76,
        feedback_amplification: 0.72,
        hidden_stress: 0.70,
        exposure_inequality: 0.78,
        buffering_capacity: 0.42,
        modularity: 0.44,
        redundancy: 0.48,
        adaptive_response: 0.52,
        governance_quality: 0.50,
    };

    let pressure = propagation_pressure(&status);
    let capacity = containment_capacity(&status);
    let risk = clamp_01(0.74 * pressure - 0.26 * capacity);
    let damage = nonlinear_damage(status.shock_intensity, status.threshold_proximity);

    println!("System: {}", status.name);
    println!("Propagation pressure score: {:.3}", pressure);
    println!("Containment capacity score: {:.3}", capacity);
    println!("Nonlinear propagation risk score: {:.3}", risk);
    println!("Propagation resilience margin: {:.3}", capacity - pressure);
    println!("Nonlinear damage proxy: {:.3}", damage);
    println!("Propagation band: {}", propagation_band(risk));
}

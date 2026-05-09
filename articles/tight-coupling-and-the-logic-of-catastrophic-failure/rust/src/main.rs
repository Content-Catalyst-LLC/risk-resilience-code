#[derive(Debug)]
struct TightCouplingStatus {
    name: String,
    coupling_strength: f64,
    time_compression: f64,
    sequence_rigidity: f64,
    limited_substitution: f64,
    interactive_complexity: f64,
    hidden_dependency: f64,
    critical_node_importance: f64,
    buffering: f64,
    modularity: f64,
    redundancy: f64,
    adaptive_authority: f64,
    fallback_capacity: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn tight_coupling_pressure(status: &TightCouplingStatus) -> f64 {
    clamp_01(
        0.16 * status.coupling_strength
            + 0.16 * status.time_compression
            + 0.14 * status.sequence_rigidity
            + 0.13 * status.limited_substitution
            + 0.15 * status.interactive_complexity
            + 0.12 * status.hidden_dependency
            + 0.14 * status.critical_node_importance,
    )
}

fn resilience_room(status: &TightCouplingStatus) -> f64 {
    clamp_01(
        0.22 * status.buffering
            + 0.20 * status.modularity
            + 0.20 * status.redundancy
            + 0.20 * status.adaptive_authority
            + 0.18 * status.fallback_capacity,
    )
}

fn failure_risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Severe tight-coupling catastrophic-failure risk"
    } else if score >= 0.60 {
        "High tight-coupling catastrophic-failure risk"
    } else if score >= 0.40 {
        "Moderate tight-coupling catastrophic-failure risk"
    } else {
        "Lower tight-coupling catastrophic-failure risk"
    }
}

fn main() {
    let status = TightCouplingStatus {
        name: "High-speed digital-infrastructure dependency".to_string(),
        coupling_strength: 0.84,
        time_compression: 0.86,
        sequence_rigidity: 0.74,
        limited_substitution: 0.78,
        interactive_complexity: 0.80,
        hidden_dependency: 0.72,
        critical_node_importance: 0.82,
        buffering: 0.38,
        modularity: 0.42,
        redundancy: 0.44,
        adaptive_authority: 0.46,
        fallback_capacity: 0.36,
    };

    let pressure = tight_coupling_pressure(&status);
    let room = resilience_room(&status);
    let risk = clamp_01(0.74 * pressure - 0.26 * room);

    println!("System: {}", status.name);
    println!("Tight-coupling pressure score: {:.3}", pressure);
    println!("Resilience room score: {:.3}", room);
    println!("Catastrophic-failure risk score: {:.3}", risk);
    println!("Containment margin: {:.3}", room - pressure);
    println!("Failure risk band: {}", failure_risk_band(risk));
}

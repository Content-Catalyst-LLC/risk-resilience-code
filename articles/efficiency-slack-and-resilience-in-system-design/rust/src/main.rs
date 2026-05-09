#[derive(Debug)]
struct SystemDesignStatus {
    name: String,
    routine_efficiency: f64,
    protective_slack: f64,
    redundancy: f64,
    modularity: f64,
    diversity: f64,
    feedback_monitoring: f64,
    repair_capacity: f64,
    governance_quality: f64,
    tight_coupling: f64,
    single_point_dependence: f64,
    overload: f64,
    deferred_maintenance: f64,
    hidden_risk_transfer: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_capacity(status: &SystemDesignStatus) -> f64 {
    clamp_01(
        0.12 * status.routine_efficiency
            + 0.16 * status.protective_slack
            + 0.14 * status.redundancy
            + 0.13 * status.modularity
            + 0.12 * status.diversity
            + 0.12 * status.feedback_monitoring
            + 0.11 * status.repair_capacity
            + 0.10 * status.governance_quality,
    )
}

fn optimization_fragility_pressure(status: &SystemDesignStatus) -> f64 {
    clamp_01(
        0.22 * status.tight_coupling
            + 0.22 * status.single_point_dependence
            + 0.20 * status.overload
            + 0.18 * status.deferred_maintenance
            + 0.18 * status.hidden_risk_transfer,
    )
}

fn design_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Resilient efficiency"
    } else if score >= 0.60 {
        "Moderate resilience-aware performance"
    } else if score >= 0.40 {
        "Limited resilience-aware performance"
    } else {
        "Fragility-producing optimization"
    }
}

fn main() {
    let status = SystemDesignStatus {
        name: "Under-buffered public service system".to_string(),
        routine_efficiency: 0.76,
        protective_slack: 0.36,
        redundancy: 0.40,
        modularity: 0.44,
        diversity: 0.42,
        feedback_monitoring: 0.50,
        repair_capacity: 0.46,
        governance_quality: 0.48,
        tight_coupling: 0.68,
        single_point_dependence: 0.66,
        overload: 0.80,
        deferred_maintenance: 0.70,
        hidden_risk_transfer: 0.74,
    };

    let capacity = resilience_capacity(&status);
    let pressure = optimization_fragility_pressure(&status);
    let performance = clamp_01(0.70 * capacity - 0.30 * pressure);

    println!("System: {}", status.name);
    println!("Resilience capacity score: {:.3}", capacity);
    println!("Optimization fragility pressure score: {:.3}", pressure);
    println!("Resilience-aware performance score: {:.3}", performance);
    println!("Slack-fragility gap: {:.3}", capacity - pressure);
    println!("System design band: {}", design_band(performance));
}

#[derive(Debug)]
struct MonitoringStatus {
    name: String,
    observation_coverage: f64,
    data_quality: f64,
    timeliness: f64,
    interoperability: f64,
    analytical_capacity: f64,
    warning_dissemination: f64,
    community_validation: f64,
    action_linkage: f64,
    rights_safeguards: f64,
    blind_spots: f64,
    uncertainty_burden: f64,
    decision_lag: f64,
    maintenance_risk: f64,
    misuse_risk: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn monitoring_capacity(status: &MonitoringStatus) -> f64 {
    clamp_01(
        0.15 * status.observation_coverage
            + 0.14 * status.data_quality
            + 0.13 * status.timeliness
            + 0.12 * status.interoperability
            + 0.12 * status.analytical_capacity
            + 0.11 * status.warning_dissemination
            + 0.09 * status.community_validation
            + 0.09 * status.action_linkage
            + 0.05 * status.rights_safeguards,
    )
}

fn monitoring_risk_pressure(status: &MonitoringStatus) -> f64 {
    clamp_01(
        0.24 * status.blind_spots
            + 0.20 * status.uncertainty_burden
            + 0.20 * status.decision_lag
            + 0.18 * status.maintenance_risk
            + 0.18 * status.misuse_risk,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong monitoring-supported resilience"
    } else if score >= 0.60 {
        "Moderate monitoring-supported resilience"
    } else if score >= 0.40 {
        "Limited monitoring-supported resilience"
    } else {
        "Weak monitoring-supported resilience"
    }
}

fn main() {
    let status = MonitoringStatus {
        name: "Community-validated watershed monitoring system".to_string(),
        observation_coverage: 0.70,
        data_quality: 0.66,
        timeliness: 0.68,
        interoperability: 0.58,
        analytical_capacity: 0.60,
        warning_dissemination: 0.64,
        community_validation: 0.72,
        action_linkage: 0.57,
        rights_safeguards: 0.69,
        blind_spots: 0.36,
        uncertainty_burden: 0.34,
        decision_lag: 0.42,
        maintenance_risk: 0.32,
        misuse_risk: 0.28,
    };

    let capacity = monitoring_capacity(&status);
    let pressure = monitoring_risk_pressure(&status);
    let resilience = clamp_01(
        0.72 * capacity + 0.18 * status.action_linkage + 0.10 * status.rights_safeguards - 0.22 * pressure,
    );

    println!("Monitoring system: {}", status.name);
    println!("Monitoring capacity score: {:.3}", capacity);
    println!("Monitoring risk pressure score: {:.3}", pressure);
    println!("Monitoring-supported resilience score: {:.3}", resilience);
    println!("Monitoring action gap: {:.3}", capacity - status.action_linkage);
    println!("Resilience band: {}", resilience_band(resilience));
}

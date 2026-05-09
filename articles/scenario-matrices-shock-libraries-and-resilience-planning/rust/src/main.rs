#[derive(Debug)]
struct ScenarioPlanningStatus {
    name: String,
    scenario_matrix_quality: f64,
    shock_library_reliability: f64,
    planning_actionability: f64,
    adaptive_decision_capacity: f64,
    blind_spot_pressure: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_planning_readiness(status: &ScenarioPlanningStatus) -> f64 {
    clamp_01(
        0.28 * status.scenario_matrix_quality
            + 0.24 * status.shock_library_reliability
            + 0.22 * status.planning_actionability
            + 0.14 * status.adaptive_decision_capacity
            + 0.12 * (1.0 - status.blind_spot_pressure),
    )
}

fn planning_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong scenario-based resilience planning"
    } else if score >= 0.60 {
        "Moderate scenario-based resilience planning"
    } else if score >= 0.40 {
        "Limited scenario-based resilience planning"
    } else {
        "Weak scenario-based resilience planning"
    }
}

fn main() {
    let status = ScenarioPlanningStatus {
        name: "Regional Shock Library and Scenario Matrix".to_string(),
        scenario_matrix_quality: 0.71,
        shock_library_reliability: 0.68,
        planning_actionability: 0.65,
        adaptive_decision_capacity: 0.62,
        blind_spot_pressure: 0.33,
    };

    let score = resilience_planning_readiness(&status);

    println!("Planning system: {}", status.name);
    println!("Resilience-planning readiness: {:.3}", score);
    println!("Planning band: {}", planning_band(score));
}

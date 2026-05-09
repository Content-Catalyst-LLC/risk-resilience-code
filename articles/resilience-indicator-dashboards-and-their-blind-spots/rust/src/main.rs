#[derive(Debug)]
struct DashboardStatus {
    name: String,
    dashboard_strength: f64,
    blind_spot_risk: f64,
    dashboard_actionability: f64,
    equity_visibility: f64,
    community_validation: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn equity_adjusted_dashboard_reliability(status: &DashboardStatus) -> f64 {
    clamp_01(
        0.34 * status.dashboard_strength
            + 0.24 * status.dashboard_actionability
            + 0.18 * (1.0 - status.blind_spot_risk)
            + 0.14 * status.equity_visibility
            + 0.10 * status.community_validation,
    )
}

fn dashboard_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong resilience dashboard reliability"
    } else if score >= 0.60 {
        "Moderate resilience dashboard reliability"
    } else if score >= 0.40 {
        "Limited resilience dashboard reliability"
    } else {
        "Weak resilience dashboard reliability"
    }
}

fn main() {
    let status = DashboardStatus {
        name: "Public Institution Resilience Dashboard".to_string(),
        dashboard_strength: 0.70,
        blind_spot_risk: 0.36,
        dashboard_actionability: 0.65,
        equity_visibility: 0.63,
        community_validation: 0.57,
    };

    let score = equity_adjusted_dashboard_reliability(&status);

    println!("Dashboard: {}", status.name);
    println!("Equity-adjusted dashboard reliability: {:.3}", score);
    println!("Dashboard band: {}", dashboard_band(score));
}

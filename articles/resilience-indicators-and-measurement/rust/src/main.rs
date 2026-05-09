#[derive(Debug)]
struct IndicatorStatus {
    name: String,
    capacity_asset_process: f64,
    performance_outcome: f64,
    measurement_vulnerability: f64,
    equity_protection: f64,
    financial_protection: f64,
    distributional_inequality: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn equity_adjusted_resilience(status: &IndicatorStatus) -> f64 {
    let measured = 0.30 * status.capacity_asset_process
        + 0.30 * status.performance_outcome
        + 0.16 * status.equity_protection
        + 0.12 * status.financial_protection
        + 0.12 * (1.0 - status.measurement_vulnerability);

    clamp_01(
        measured
            - 0.25 * status.distributional_inequality
            - 0.15 * (1.0 - status.equity_protection),
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong equity-adjusted measured resilience"
    } else if score >= 0.60 {
        "Moderate equity-adjusted measured resilience"
    } else if score >= 0.40 {
        "Limited equity-adjusted measured resilience"
    } else {
        "Weak equity-adjusted measured resilience"
    }
}

fn main() {
    let status = IndicatorStatus {
        name: "Public Service Resilience Measurement System".to_string(),
        capacity_asset_process: 0.71,
        performance_outcome: 0.68,
        measurement_vulnerability: 0.32,
        equity_protection: 0.64,
        financial_protection: 0.60,
        distributional_inequality: 0.29,
    };

    let score = equity_adjusted_resilience(&status);

    println!("System: {}", status.name);
    println!("Equity-adjusted measured resilience: {:.3}", score);
    println!("Resilience band: {}", resilience_band(score));
}

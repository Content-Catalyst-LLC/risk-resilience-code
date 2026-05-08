#[derive(Debug)]
struct WarningStatus {
    name: String,
    warning_effectiveness: f64,
    preparedness_system: f64,
    warning_vulnerability: f64,
    equity_access: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn early_action_readiness(status: &WarningStatus) -> f64 {
    clamp_01(
        0.38 * status.warning_effectiveness
            + 0.32 * status.preparedness_system
            + 0.18 * (1.0 - status.warning_vulnerability)
            + 0.12 * status.equity_access,
    )
}

fn readiness_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong early warning and preparedness readiness"
    } else if score >= 0.60 {
        "Moderate early warning and preparedness readiness"
    } else if score >= 0.40 {
        "Limited early warning and preparedness readiness"
    } else {
        "Weak early warning and preparedness readiness"
    }
}

fn main() {
    let status = WarningStatus {
        name: "Urban Heat Early Warning System".to_string(),
        warning_effectiveness: 0.71,
        preparedness_system: 0.67,
        warning_vulnerability: 0.42,
        equity_access: 0.62,
    };

    let score = early_action_readiness(&status);

    println!("Warning system: {}", status.name);
    println!("Early action readiness score: {:.3}", score);
    println!("Readiness band: {}", readiness_band(score));
}

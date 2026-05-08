#[derive(Debug)]
struct FinanceStatus {
    name: String,
    resilience_finance_capacity: f64,
    protection_gap_pressure: f64,
    risk_visibility_governance: f64,
    systemic_transmission_risk: f64,
    debt_stress: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn resilience_adjusted_financial_risk(status: &FinanceStatus) -> f64 {
    clamp_01(
        0.34 * status.protection_gap_pressure
            + 0.24 * (1.0 - status.resilience_finance_capacity)
            + 0.16 * (1.0 - status.risk_visibility_governance)
            + 0.14 * status.systemic_transmission_risk
            + 0.12 * status.debt_stress,
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme resilience finance risk"
    } else if score >= 0.60 {
        "High resilience finance risk"
    } else if score >= 0.40 {
        "Moderate resilience finance risk"
    } else {
        "Lower resilience finance risk"
    }
}

fn main() {
    let status = FinanceStatus {
        name: "Public Asset Insurance and Resilience Investment System".to_string(),
        resilience_finance_capacity: 0.69,
        protection_gap_pressure: 0.47,
        risk_visibility_governance: 0.66,
        systemic_transmission_risk: 0.44,
        debt_stress: 0.39,
    };

    let score = resilience_adjusted_financial_risk(&status);

    println!("Risk finance system: {}", status.name);
    println!("Resilience-adjusted financial risk: {:.3}", score);
    println!("Risk band: {}", risk_band(score));
}

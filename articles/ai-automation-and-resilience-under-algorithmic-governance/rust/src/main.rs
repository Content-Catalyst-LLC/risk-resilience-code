#[derive(Debug)]
struct AIResilienceStatus {
    name: String,
    model_capability: f64,
    institutional_governance: f64,
    data_quality: f64,
    human_oversight: f64,
    system_robustness: f64,
    auditability: f64,
    opacity_risk: f64,
    bias_severity: f64,
    model_drift_risk: f64,
    automation_dependency: f64,
    cyber_exposure: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn algorithmic_resilience(status: &AIResilienceStatus) -> f64 {
    clamp_01(
        0.13 * status.model_capability
            + 0.13 * status.institutional_governance
            + 0.11 * status.data_quality
            + 0.12 * status.human_oversight
            + 0.11 * status.system_robustness
            + 0.10 * status.auditability
            - 0.08 * status.opacity_risk
            - 0.07 * status.bias_severity
            - 0.06 * status.model_drift_risk
            - 0.05 * status.automation_dependency
            - 0.04 * status.cyber_exposure,
    )
}

fn readiness_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong algorithmic resilience readiness"
    } else if score >= 0.60 {
        "Moderate algorithmic resilience readiness"
    } else if score >= 0.40 {
        "Limited algorithmic resilience readiness"
    } else {
        "Weak algorithmic resilience readiness"
    }
}

fn main() {
    let status = AIResilienceStatus {
        name: "AI-enabled public resilience system".to_string(),
        model_capability: 0.74,
        institutional_governance: 0.66,
        data_quality: 0.70,
        human_oversight: 0.63,
        system_robustness: 0.68,
        auditability: 0.62,
        opacity_risk: 0.31,
        bias_severity: 0.28,
        model_drift_risk: 0.34,
        automation_dependency: 0.40,
        cyber_exposure: 0.36,
    };

    let score = algorithmic_resilience(&status);

    println!("System: {}", status.name);
    println!("Algorithmic resilience score: {:.3}", score);
    println!("Readiness band: {}", readiness_band(score));
}

#[derive(Debug)]
struct PublicInstitutionStatus {
    name: String,
    anticipatory_foresight: f64,
    continuity_operations: f64,
    administrative_capacity: f64,
    coordination_capacity: f64,
    risk_informed_finance: f64,
    procurement_resilience: f64,
    digital_fallback: f64,
    public_legitimacy: f64,
    justice_service_equity: f64,
    learning_adaptation: f64,
    fragmentation_risk: f64,
    underinvestment_risk: f64,
    staffing_fragility: f64,
    digital_dependency_risk: f64,
    accountability_gap: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn institutional_resilience(status: &PublicInstitutionStatus) -> f64 {
    clamp_01(
        0.12 * status.anticipatory_foresight
            + 0.12 * status.continuity_operations
            + 0.11 * status.administrative_capacity
            + 0.10 * status.coordination_capacity
            + 0.09 * status.risk_informed_finance
            + 0.09 * status.procurement_resilience
            + 0.07 * status.digital_fallback
            + 0.07 * status.public_legitimacy
            + 0.07 * status.justice_service_equity
            + 0.06 * status.learning_adaptation
            - 0.04 * status.fragmentation_risk
            - 0.04 * status.underinvestment_risk
            - 0.03 * status.staffing_fragility
            - 0.03 * status.digital_dependency_risk
            - 0.02 * status.accountability_gap,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong public institutional resilience"
    } else if score >= 0.60 {
        "Moderate public institutional resilience"
    } else if score >= 0.40 {
        "Limited public institutional resilience"
    } else {
        "Weak public institutional resilience"
    }
}

fn main() {
    let status = PublicInstitutionStatus {
        name: "Public institutional resilience program".to_string(),
        anticipatory_foresight: 0.68,
        continuity_operations: 0.72,
        administrative_capacity: 0.65,
        coordination_capacity: 0.63,
        risk_informed_finance: 0.60,
        procurement_resilience: 0.58,
        digital_fallback: 0.61,
        public_legitimacy: 0.66,
        justice_service_equity: 0.64,
        learning_adaptation: 0.62,
        fragmentation_risk: 0.30,
        underinvestment_risk: 0.34,
        staffing_fragility: 0.32,
        digital_dependency_risk: 0.36,
        accountability_gap: 0.28,
    };

    let score = institutional_resilience(&status);

    println!("Institution: {}", status.name);
    println!("Public institutional resilience score: {:.3}", score);
    println!("Resilience band: {}", resilience_band(score));
}

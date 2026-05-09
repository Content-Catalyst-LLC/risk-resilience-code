#[derive(Debug)]
struct LockInStatus {
    name: String,
    sunk_cost: f64,
    infrastructure_rigidity: f64,
    institutional_inertia: f64,
    incumbent_power: f64,
    social_dependence: f64,
    technological_incompatibility: f64,
    ecological_feedback: f64,
    alternative_capacity: f64,
    adaptive_governance: f64,
    public_legitimacy: f64,
    justice_transition: f64,
    reversibility: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn lock_in_pressure(status: &LockInStatus) -> f64 {
    clamp_01(
        0.16 * status.sunk_cost
            + 0.16 * status.infrastructure_rigidity
            + 0.16 * status.institutional_inertia
            + 0.16 * status.incumbent_power
            + 0.14 * status.social_dependence
            + 0.11 * status.technological_incompatibility
            + 0.11 * status.ecological_feedback,
    )
}

fn transformation_capacity(status: &LockInStatus) -> f64 {
    clamp_01(
        0.22 * status.alternative_capacity
            + 0.22 * status.adaptive_governance
            + 0.18 * status.public_legitimacy
            + 0.20 * status.justice_transition
            + 0.18 * status.reversibility,
    )
}

fn trap_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Severe resilience trap risk"
    } else if score >= 0.60 {
        "High resilience trap risk"
    } else if score >= 0.40 {
        "Moderate resilience trap risk"
    } else {
        "Lower resilience trap risk"
    }
}

fn main() {
    let status = LockInStatus {
        name: "Flood-prone development pathway".to_string(),
        sunk_cost: 0.78,
        infrastructure_rigidity: 0.82,
        institutional_inertia: 0.74,
        incumbent_power: 0.70,
        social_dependence: 0.76,
        technological_incompatibility: 0.56,
        ecological_feedback: 0.64,
        alternative_capacity: 0.42,
        adaptive_governance: 0.46,
        public_legitimacy: 0.52,
        justice_transition: 0.40,
        reversibility: 0.34,
    };

    let pressure = lock_in_pressure(&status);
    let capacity = transformation_capacity(&status);
    let trap_risk = clamp_01(0.72 * pressure - 0.28 * capacity);
    let readiness = clamp_01(0.68 * capacity - 0.32 * pressure);

    println!("System: {}", status.name);
    println!("Lock-in pressure score: {:.3}", pressure);
    println!("Transformation capacity score: {:.3}", capacity);
    println!("Resilience trap risk score: {:.3}", trap_risk);
    println!("Transformation readiness score: {:.3}", readiness);
    println!("Escape gap: {:.3}", capacity - pressure);
    println!("Trap band: {}", trap_band(trap_risk));
}

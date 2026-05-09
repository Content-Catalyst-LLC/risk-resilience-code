#[derive(Debug)]
struct IntegratedGovernanceStatus {
    name: String,
    cross_sector_coordination: f64,
    dependency_visibility: f64,
    governance_integration: f64,
    data_interoperability: f64,
    public_accountability: f64,
    justice_equity: f64,
    local_capability: f64,
    adaptive_learning: f64,
    fragmentation_risk: f64,
    mandate_conflict: f64,
    governance_data_gap: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn integrated_governance_capacity(status: &IntegratedGovernanceStatus) -> f64 {
    clamp_01(
        0.15 * status.cross_sector_coordination
            + 0.13 * status.dependency_visibility
            + 0.12 * status.governance_integration
            + 0.10 * status.data_interoperability
            + 0.10 * status.public_accountability
            + 0.09 * status.justice_equity
            + 0.08 * status.local_capability
            + 0.08 * status.adaptive_learning
            - 0.06 * status.fragmentation_risk
            - 0.05 * status.mandate_conflict
            - 0.04 * status.governance_data_gap,
    )
}

fn governance_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong integrated resilience governance capacity"
    } else if score >= 0.60 {
        "Moderate integrated resilience governance capacity"
    } else if score >= 0.40 {
        "Limited integrated resilience governance capacity"
    } else {
        "Weak integrated resilience governance capacity"
    }
}

fn main() {
    let status = IntegratedGovernanceStatus {
        name: "Regional integrated resilience governance system".to_string(),
        cross_sector_coordination: 0.70,
        dependency_visibility: 0.64,
        governance_integration: 0.66,
        data_interoperability: 0.61,
        public_accountability: 0.63,
        justice_equity: 0.62,
        local_capability: 0.68,
        adaptive_learning: 0.60,
        fragmentation_risk: 0.31,
        mandate_conflict: 0.28,
        governance_data_gap: 0.30,
    };

    let score = integrated_governance_capacity(&status);

    println!("Governance system: {}", status.name);
    println!("Integrated governance capacity score: {:.3}", score);
    println!("Readiness band: {}", governance_band(score));
}

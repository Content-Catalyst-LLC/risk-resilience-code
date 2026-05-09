#[derive(Debug)]
struct RegenerativeResilienceStatus {
    name: String,
    ecosystem_integrity: f64,
    biodiversity: f64,
    soil_health: f64,
    water_function: f64,
    connectivity: f64,
    local_stewardship: f64,
    governance_accountability: f64,
    justice_repair: f64,
    degradation_pressure: f64,
    fragmentation_pressure: f64,
    extraction_pressure: f64,
    maladaptation_risk: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn regenerative_resilience(status: &RegenerativeResilienceStatus) -> f64 {
    clamp_01(
        0.13 * status.ecosystem_integrity
            + 0.12 * status.biodiversity
            + 0.12 * status.soil_health
            + 0.11 * status.water_function
            + 0.10 * status.connectivity
            + 0.09 * status.local_stewardship
            + 0.09 * status.governance_accountability
            + 0.08 * status.justice_repair
            - 0.06 * status.degradation_pressure
            - 0.04 * status.fragmentation_pressure
            - 0.03 * status.extraction_pressure
            - 0.03 * status.maladaptation_risk,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong regenerative resilience"
    } else if score >= 0.60 {
        "Moderate regenerative resilience"
    } else if score >= 0.40 {
        "Limited regenerative resilience"
    } else {
        "Weak regenerative resilience"
    }
}

fn main() {
    let status = RegenerativeResilienceStatus {
        name: "Living-systems repair landscape".to_string(),
        ecosystem_integrity: 0.68,
        biodiversity: 0.70,
        soil_health: 0.66,
        water_function: 0.63,
        connectivity: 0.61,
        local_stewardship: 0.64,
        governance_accountability: 0.58,
        justice_repair: 0.55,
        degradation_pressure: 0.36,
        fragmentation_pressure: 0.34,
        extraction_pressure: 0.30,
        maladaptation_risk: 0.28,
    };

    let score = regenerative_resilience(&status);

    println!("System: {}", status.name);
    println!("Regenerative resilience score: {:.3}", score);
    println!("Resilience band: {}", resilience_band(score));
}

#[derive(Debug)]
struct DrinkingWaterStatus {
    name: String,
    source_protection: f64,
    treatment_capacity: f64,
    distribution_reliability: f64,
    monitoring_quality: f64,
    supply_diversity: f64,
    energy_resilience: f64,
    affordability: f64,
    governance_capacity: f64,
    contamination_risk: f64,
    infrastructure_aging: f64,
    salinity_pressure: f64,
    energy_dependence: f64,
    brine_burden: f64,
    access_inequality: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn water_resilience_capacity(status: &DrinkingWaterStatus) -> f64 {
    clamp_01(
        0.15 * status.source_protection
            + 0.16 * status.treatment_capacity
            + 0.15 * status.distribution_reliability
            + 0.14 * status.monitoring_quality
            + 0.11 * status.supply_diversity
            + 0.10 * status.energy_resilience
            + 0.09 * status.affordability
            + 0.10 * status.governance_capacity,
    )
}

fn water_system_risk_pressure(status: &DrinkingWaterStatus) -> f64 {
    clamp_01(
        0.22 * status.contamination_risk
            + 0.18 * status.infrastructure_aging
            + 0.16 * status.salinity_pressure
            + 0.15 * status.energy_dependence
            + 0.13 * status.brine_burden
            + 0.16 * status.access_inequality,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong drinking-water resilience"
    } else if score >= 0.60 {
        "Moderate drinking-water resilience"
    } else if score >= 0.40 {
        "Limited drinking-water resilience"
    } else {
        "Weak drinking-water resilience"
    }
}

fn main() {
    let status = DrinkingWaterStatus {
        name: "Urban source-to-tap drinking-water system".to_string(),
        source_protection: 0.66,
        treatment_capacity: 0.76,
        distribution_reliability: 0.60,
        monitoring_quality: 0.72,
        supply_diversity: 0.62,
        energy_resilience: 0.56,
        affordability: 0.48,
        governance_capacity: 0.64,
        contamination_risk: 0.42,
        infrastructure_aging: 0.60,
        salinity_pressure: 0.38,
        energy_dependence: 0.58,
        brine_burden: 0.30,
        access_inequality: 0.54,
    };

    let capacity = water_resilience_capacity(&status);
    let pressure = water_system_risk_pressure(&status);
    let resilience = clamp_01(0.72 * capacity - 0.28 * pressure);

    println!("Water system: {}", status.name);
    println!("Water resilience capacity score: {:.3}", capacity);
    println!("Water-system risk pressure score: {:.3}", pressure);
    println!("Drinking-water resilience score: {:.3}", resilience);
    println!("Source-to-tap resilience gap: {:.3}", capacity - pressure);
    println!("Resilience band: {}", resilience_band(resilience));
}

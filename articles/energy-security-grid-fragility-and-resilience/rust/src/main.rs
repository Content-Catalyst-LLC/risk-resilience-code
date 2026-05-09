#[derive(Debug)]
struct EnergySystemStatus {
    name: String,
    reliability: f64,
    adequacy: f64,
    redundancy: f64,
    flexibility: f64,
    distributed_capacity: f64,
    cyber_resilience: f64,
    restoration_capacity: f64,
    critical_load_protection: f64,
    affordability: f64,
    equity_protection: f64,
    climate_exposure: f64,
    infrastructure_aging: f64,
    fuel_dependence: f64,
    digital_fragility: f64,
    load_growth_pressure: f64,
    interdependency_risk: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn energy_resilience_capacity(status: &EnergySystemStatus) -> f64 {
    clamp_01(
        0.14 * status.reliability
            + 0.13 * status.adequacy
            + 0.13 * status.redundancy
            + 0.12 * status.flexibility
            + 0.11 * status.distributed_capacity
            + 0.11 * status.cyber_resilience
            + 0.13 * status.restoration_capacity
            + 0.13 * status.critical_load_protection,
    )
}

fn grid_fragility_pressure(status: &EnergySystemStatus) -> f64 {
    clamp_01(
        0.18 * status.climate_exposure
            + 0.17 * status.infrastructure_aging
            + 0.15 * status.fuel_dependence
            + 0.15 * status.digital_fragility
            + 0.18 * status.load_growth_pressure
            + 0.17 * status.interdependency_risk,
    )
}

fn just_energy_resilience(status: &EnergySystemStatus) -> f64 {
    clamp_01(
        0.24 * status.affordability
            + 0.24 * status.equity_protection
            + 0.22 * status.critical_load_protection
            + 0.16 * status.distributed_capacity
            + 0.14 * status.restoration_capacity,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong energy security resilience"
    } else if score >= 0.60 {
        "Moderate energy security resilience"
    } else if score >= 0.40 {
        "Limited energy security resilience"
    } else {
        "Weak energy security resilience"
    }
}

fn main() {
    let status = EnergySystemStatus {
        name: "Electrifying urban-regional energy system".to_string(),
        reliability: 0.70,
        adequacy: 0.66,
        redundancy: 0.55,
        flexibility: 0.64,
        distributed_capacity: 0.58,
        cyber_resilience: 0.61,
        restoration_capacity: 0.65,
        critical_load_protection: 0.62,
        affordability: 0.48,
        equity_protection: 0.44,
        climate_exposure: 0.74,
        infrastructure_aging: 0.60,
        fuel_dependence: 0.42,
        digital_fragility: 0.60,
        load_growth_pressure: 0.78,
        interdependency_risk: 0.70,
    };

    let capacity = energy_resilience_capacity(&status);
    let fragility = grid_fragility_pressure(&status);
    let justice = just_energy_resilience(&status);
    let overall = clamp_01(0.58 * capacity + 0.22 * justice - 0.28 * fragility);

    println!("Energy system: {}", status.name);
    println!("Energy resilience capacity score: {:.3}", capacity);
    println!("Grid fragility pressure score: {:.3}", fragility);
    println!("Just energy resilience score: {:.3}", justice);
    println!("Energy-security resilience score: {:.3}", overall);
    println!("Resilience-fragility gap: {:.3}", capacity - fragility);
    println!("Resilience band: {}", resilience_band(overall));
}

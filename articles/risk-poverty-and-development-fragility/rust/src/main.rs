#[derive(Debug)]
struct PovertyFragilityStatus {
    name: String,
    risk_exposure: f64,
    multidimensional_poverty: f64,
    institutional_weakness: f64,
    livelihood_precarity: f64,
    service_deficit: f64,
    conflict_pressure: f64,
    climate_stress: f64,
    displacement_pressure: f64,
    social_protection: f64,
    household_buffers: f64,
    adaptive_capacity: f64,
    service_continuity: f64,
    institutional_trust: f64,
    community_voice: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn development_fragility(status: &PovertyFragilityStatus) -> f64 {
    clamp_01(
        0.18 * status.risk_exposure
            + 0.17 * status.multidimensional_poverty
            + 0.15 * status.institutional_weakness
            + 0.14 * status.livelihood_precarity
            + 0.13 * status.service_deficit
            + 0.10 * status.conflict_pressure
            + 0.08 * status.climate_stress
            + 0.05 * status.displacement_pressure,
    )
}

fn resilience_sufficiency(status: &PovertyFragilityStatus) -> f64 {
    clamp_01(
        0.18 * status.social_protection
            + 0.17 * status.household_buffers
            + 0.17 * status.adaptive_capacity
            + 0.16 * status.service_continuity
            + 0.16 * status.institutional_trust
            + 0.16 * status.community_voice,
    )
}

fn fragility_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Extreme development fragility"
    } else if score >= 0.60 {
        "High development fragility"
    } else if score >= 0.40 {
        "Moderate development fragility"
    } else {
        "Lower development fragility"
    }
}

fn main() {
    let status = PovertyFragilityStatus {
        name: "Under-buffered poverty-fragility region".to_string(),
        risk_exposure: 0.70,
        multidimensional_poverty: 0.66,
        institutional_weakness: 0.61,
        livelihood_precarity: 0.64,
        service_deficit: 0.63,
        conflict_pressure: 0.50,
        climate_stress: 0.67,
        displacement_pressure: 0.46,
        social_protection: 0.41,
        household_buffers: 0.36,
        adaptive_capacity: 0.44,
        service_continuity: 0.39,
        institutional_trust: 0.40,
        community_voice: 0.52,
    };

    let fragility = development_fragility(&status);
    let resilience = resilience_sufficiency(&status);

    println!("Place: {}", status.name);
    println!("Development fragility score: {:.3}", fragility);
    println!("Resilience sufficiency score: {:.3}", resilience);
    println!("Poverty-fragility gap: {:.3}", resilience - fragility);
    println!("Fragility band: {}", fragility_band(fragility));
}

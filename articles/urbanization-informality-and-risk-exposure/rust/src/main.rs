#[derive(Debug)]
struct UrbanRiskStatus {
    name: String,
    flood_exposure: f64,
    heat_exposure: f64,
    landslide_or_fire_exposure: f64,
    housing_vulnerability: f64,
    infrastructure_deficit: f64,
    service_access: f64,
    tenure_security: f64,
    livelihood_precarity: f64,
    social_protection_access: f64,
    community_adaptation: f64,
    institutional_protection: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn risk_exposure(status: &UrbanRiskStatus) -> f64 {
    let hazard_exposure = 0.38 * status.flood_exposure
        + 0.34 * status.heat_exposure
        + 0.28 * status.landslide_or_fire_exposure;

    let vulnerability = 0.24 * status.housing_vulnerability
        + 0.22 * status.infrastructure_deficit
        + 0.18 * status.livelihood_precarity
        + 0.14 * (1.0 - status.tenure_security)
        + 0.10 * (1.0 - status.social_protection_access);

    clamp_01(0.45 * hazard_exposure + 0.35 * vulnerability + 0.20 * status.infrastructure_deficit)
}

fn protection_capacity(status: &UrbanRiskStatus) -> f64 {
    clamp_01(
        0.20 * status.service_access
            + 0.18 * status.tenure_security
            + 0.18 * status.community_adaptation
            + 0.17 * status.institutional_protection
            + 0.15 * status.social_protection_access
            + 0.12 * (1.0 - status.infrastructure_deficit),
    )
}

fn risk_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Severe urban risk exposure"
    } else if score >= 0.60 {
        "High urban risk exposure"
    } else if score >= 0.40 {
        "Moderate urban risk exposure"
    } else {
        "Lower urban risk exposure"
    }
}

fn main() {
    let status = UrbanRiskStatus {
        name: "Under-serviced heat-exposed informal settlement".to_string(),
        flood_exposure: 0.58,
        heat_exposure: 0.82,
        landslide_or_fire_exposure: 0.38,
        housing_vulnerability: 0.70,
        infrastructure_deficit: 0.72,
        service_access: 0.35,
        tenure_security: 0.30,
        livelihood_precarity: 0.66,
        social_protection_access: 0.28,
        community_adaptation: 0.56,
        institutional_protection: 0.33,
    };

    let risk = risk_exposure(&status);
    let protection = protection_capacity(&status);

    println!("Settlement: {}", status.name);
    println!("Risk exposure score: {:.3}", risk);
    println!("Protection capacity score: {:.3}", protection);
    println!("Protection gap: {:.3}", protection - risk);
    println!("Risk band: {}", risk_band(risk));
}

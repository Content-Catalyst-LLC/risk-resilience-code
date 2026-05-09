#[derive(Debug)]
struct InequalityResilienceStatus {
    name: String,
    system_capacity: f64,
    distributed_protection: f64,
    household_buffers: f64,
    service_access: f64,
    institutional_trust: f64,
    adaptive_capacity: f64,
    exposure_concentration: f64,
    multidimensional_deprivation: f64,
    social_exclusion: f64,
    recovery_inequality: f64,
    digital_exclusion: f64,
    fiscal_stress: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn equality_adjusted_resilience(status: &InequalityResilienceStatus) -> f64 {
    clamp_01(
        0.16 * status.system_capacity
            + 0.16 * status.distributed_protection
            + 0.14 * status.household_buffers
            + 0.14 * status.service_access
            + 0.12 * status.institutional_trust
            + 0.12 * status.adaptive_capacity
            - 0.07 * status.exposure_concentration
            - 0.04 * status.multidimensional_deprivation
            - 0.03 * status.social_exclusion
            - 0.02 * status.recovery_inequality,
    )
}

fn inequality_pressure(status: &InequalityResilienceStatus) -> f64 {
    clamp_01(
        0.22 * status.exposure_concentration
            + 0.20 * status.multidimensional_deprivation
            + 0.18 * status.social_exclusion
            + 0.16 * status.recovery_inequality
            + 0.13 * status.digital_exclusion
            + 0.11 * status.fiscal_stress,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong equality-adjusted resilience"
    } else if score >= 0.60 {
        "Moderate equality-adjusted resilience"
    } else if score >= 0.40 {
        "Limited equality-adjusted resilience"
    } else {
        "Weak equality-adjusted resilience"
    }
}

fn main() {
    let status = InequalityResilienceStatus {
        name: "Under-protected rural region".to_string(),
        system_capacity: 0.61,
        distributed_protection: 0.46,
        household_buffers: 0.40,
        service_access: 0.48,
        institutional_trust: 0.44,
        adaptive_capacity: 0.47,
        exposure_concentration: 0.60,
        multidimensional_deprivation: 0.57,
        social_exclusion: 0.52,
        recovery_inequality: 0.55,
        digital_exclusion: 0.50,
        fiscal_stress: 0.48,
    };

    let resilience = equality_adjusted_resilience(&status);
    let pressure = inequality_pressure(&status);

    println!("Place: {}", status.name);
    println!("Equality-adjusted resilience score: {:.3}", resilience);
    println!("Inequality pressure score: {:.3}", pressure);
    println!("Resilience-pressure gap: {:.3}", resilience - pressure);
    println!("Resilience band: {}", resilience_band(resilience));
}

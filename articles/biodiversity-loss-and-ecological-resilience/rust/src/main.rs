#[derive(Debug)]
struct BiodiversityResilienceStatus {
    name: String,
    genetic_diversity: f64,
    species_diversity: f64,
    functional_diversity: f64,
    habitat_connectivity: f64,
    ecosystem_integrity: f64,
    adaptive_capacity: f64,
    fragmentation_pressure: f64,
    pollution_pressure: f64,
    invasive_pressure: f64,
    extraction_pressure: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn biodiversity_resilience(status: &BiodiversityResilienceStatus) -> f64 {
    clamp_01(
        0.14 * status.genetic_diversity
            + 0.15 * status.species_diversity
            + 0.16 * status.functional_diversity
            + 0.14 * status.habitat_connectivity
            + 0.14 * status.ecosystem_integrity
            + 0.10 * status.adaptive_capacity
            - 0.07 * status.fragmentation_pressure
            - 0.04 * status.pollution_pressure
            - 0.03 * status.invasive_pressure
            - 0.03 * status.extraction_pressure,
    )
}

fn resilience_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong biodiversity-supported resilience"
    } else if score >= 0.60 {
        "Moderate biodiversity-supported resilience"
    } else if score >= 0.40 {
        "Limited biodiversity-supported resilience"
    } else {
        "Weak biodiversity-supported resilience"
    }
}

fn main() {
    let status = BiodiversityResilienceStatus {
        name: "Connected forest-wetland ecosystem".to_string(),
        genetic_diversity: 0.70,
        species_diversity: 0.74,
        functional_diversity: 0.69,
        habitat_connectivity: 0.63,
        ecosystem_integrity: 0.66,
        adaptive_capacity: 0.61,
        fragmentation_pressure: 0.34,
        pollution_pressure: 0.28,
        invasive_pressure: 0.25,
        extraction_pressure: 0.31,
    };

    let score = biodiversity_resilience(&status);

    println!("Ecosystem: {}", status.name);
    println!("Biodiversity-supported resilience score: {:.3}", score);
    println!("Resilience band: {}", resilience_band(score));
}

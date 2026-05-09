#[derive(Debug)]
struct JusticeTransformationStatus {
    name: String,
    distributive_justice: f64,
    procedural_justice: f64,
    recognition: f64,
    rights_protection: f64,
    institutional_accountability: f64,
    ecological_governance: f64,
    intergenerational_responsibility: f64,
    maladaptation_risk: f64,
    harm_shifting_risk: f64,
    exclusion_risk: f64,
    coercion_risk: f64,
}

fn clamp_01(value: f64) -> f64 {
    value.max(0.0).min(1.0)
}

fn justice_oriented_transformation(status: &JusticeTransformationStatus) -> f64 {
    clamp_01(
        0.15 * status.distributive_justice
            + 0.14 * status.procedural_justice
            + 0.12 * status.recognition
            + 0.12 * status.rights_protection
            + 0.11 * status.institutional_accountability
            + 0.10 * status.ecological_governance
            + 0.09 * status.intergenerational_responsibility
            - 0.08 * status.maladaptation_risk
            - 0.05 * status.harm_shifting_risk
            - 0.03 * status.exclusion_risk
            - 0.01 * status.coercion_risk,
    )
}

fn justice_band(score: f64) -> &'static str {
    if score >= 0.80 {
        "Strong justice-oriented transformation"
    } else if score >= 0.60 {
        "Moderate justice-oriented transformation"
    } else if score >= 0.40 {
        "Limited justice-oriented transformation"
    } else {
        "Weak justice-oriented transformation"
    }
}

fn main() {
    let status = JusticeTransformationStatus {
        name: "Just resilience transformation initiative".to_string(),
        distributive_justice: 0.68,
        procedural_justice: 0.64,
        recognition: 0.61,
        rights_protection: 0.66,
        institutional_accountability: 0.62,
        ecological_governance: 0.58,
        intergenerational_responsibility: 0.60,
        maladaptation_risk: 0.30,
        harm_shifting_risk: 0.28,
        exclusion_risk: 0.25,
        coercion_risk: 0.22,
    };

    let score = justice_oriented_transformation(&status);

    println!("Initiative: {}", status.name);
    println!("Justice-oriented transformation score: {:.3}", score);
    println!("Justice band: {}", justice_band(score));
}

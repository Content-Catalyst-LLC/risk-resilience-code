package main

import "fmt"

type PovertyFragilityStatus struct {
	Name                         string
	RiskExposure                 float64
	MultidimensionalPoverty      float64
	InstitutionalWeakness        float64
	LivelihoodPrecarity          float64
	ServiceDeficit               float64
	ConflictPressure             float64
	ClimateStress                float64
	DisplacementPressure         float64
	SocialProtection             float64
	HouseholdBuffers             float64
	AdaptiveCapacity             float64
	ServiceContinuity            float64
	InstitutionalTrust           float64
	CommunityVoice               float64
}

func clamp01(value float64) float64 {
	if value < 0 {
		return 0
	}
	if value > 1 {
		return 1
	}
	return value
}

func developmentFragility(status PovertyFragilityStatus) float64 {
	score := 0.18*status.RiskExposure +
		0.17*status.MultidimensionalPoverty +
		0.15*status.InstitutionalWeakness +
		0.14*status.LivelihoodPrecarity +
		0.13*status.ServiceDeficit +
		0.10*status.ConflictPressure +
		0.08*status.ClimateStress +
		0.05*status.DisplacementPressure

	return clamp01(score)
}

func resilienceSufficiency(status PovertyFragilityStatus) float64 {
	score := 0.18*status.SocialProtection +
		0.17*status.HouseholdBuffers +
		0.17*status.AdaptiveCapacity +
		0.16*status.ServiceContinuity +
		0.16*status.InstitutionalTrust +
		0.16*status.CommunityVoice

	return clamp01(score)
}

func fragilityBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme development fragility"
	case score >= 0.60:
		return "High development fragility"
	case score >= 0.40:
		return "Moderate development fragility"
	default:
		return "Lower development fragility"
	}
}

func main() {
	status := PovertyFragilityStatus{
		Name:                    "Fragile climate-exposed district",
		RiskExposure:            0.72,
		MultidimensionalPoverty: 0.68,
		InstitutionalWeakness:   0.60,
		LivelihoodPrecarity:     0.66,
		ServiceDeficit:          0.64,
		ConflictPressure:        0.55,
		ClimateStress:           0.62,
		DisplacementPressure:    0.50,
		SocialProtection:        0.42,
		HouseholdBuffers:        0.38,
		AdaptiveCapacity:        0.45,
		ServiceContinuity:       0.40,
		InstitutionalTrust:      0.43,
		CommunityVoice:          0.51,
	}

	fragility := developmentFragility(status)
	resilience := resilienceSufficiency(status)

	fmt.Printf("Place: %s\n", status.Name)
	fmt.Printf("Development fragility score: %.3f\n", fragility)
	fmt.Printf("Resilience sufficiency score: %.3f\n", resilience)
	fmt.Printf("Poverty-fragility gap: %.3f\n", resilience-fragility)
	fmt.Printf("Fragility band: %s\n", fragilityBand(fragility))
}

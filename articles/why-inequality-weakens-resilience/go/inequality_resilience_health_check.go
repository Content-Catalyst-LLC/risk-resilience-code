package main

import "fmt"

type InequalityResilienceStatus struct {
	Name                         string
	SystemCapacity               float64
	DistributedProtection        float64
	HouseholdBuffers             float64
	ServiceAccess                float64
	InstitutionalTrust           float64
	AdaptiveCapacity             float64
	ExposureConcentration        float64
	MultidimensionalDeprivation  float64
	SocialExclusion              float64
	RecoveryInequality           float64
	DigitalExclusion             float64
	FiscalStress                 float64
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

func equalityAdjustedResilience(status InequalityResilienceStatus) float64 {
	score := 0.16*status.SystemCapacity +
		0.16*status.DistributedProtection +
		0.14*status.HouseholdBuffers +
		0.14*status.ServiceAccess +
		0.12*status.InstitutionalTrust +
		0.12*status.AdaptiveCapacity -
		0.07*status.ExposureConcentration -
		0.04*status.MultidimensionalDeprivation -
		0.03*status.SocialExclusion -
		0.02*status.RecoveryInequality

	return clamp01(score)
}

func inequalityPressure(status InequalityResilienceStatus) float64 {
	score := 0.22*status.ExposureConcentration +
		0.20*status.MultidimensionalDeprivation +
		0.18*status.SocialExclusion +
		0.16*status.RecoveryInequality +
		0.13*status.DigitalExclusion +
		0.11*status.FiscalStress

	return clamp01(score)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong equality-adjusted resilience"
	case score >= 0.60:
		return "Moderate equality-adjusted resilience"
	case score >= 0.40:
		return "Limited equality-adjusted resilience"
	default:
		return "Weak equality-adjusted resilience"
	}
}

func main() {
	status := InequalityResilienceStatus{
		Name:                        "Under-protected metropolitan district",
		SystemCapacity:              0.67,
		DistributedProtection:       0.48,
		HouseholdBuffers:            0.43,
		ServiceAccess:               0.52,
		InstitutionalTrust:          0.46,
		AdaptiveCapacity:            0.50,
		ExposureConcentration:       0.62,
		MultidimensionalDeprivation: 0.58,
		SocialExclusion:             0.54,
		RecoveryInequality:          0.57,
		DigitalExclusion:            0.49,
		FiscalStress:                0.45,
	}

	resilience := equalityAdjustedResilience(status)
	pressure := inequalityPressure(status)

	fmt.Printf("Place: %s\n", status.Name)
	fmt.Printf("Equality-adjusted resilience score: %.3f\n", resilience)
	fmt.Printf("Inequality pressure score: %.3f\n", pressure)
	fmt.Printf("Resilience-pressure gap: %.3f\n", resilience-pressure)
	fmt.Printf("Resilience band: %s\n", resilienceBand(resilience))
}

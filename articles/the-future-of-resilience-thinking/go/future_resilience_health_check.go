package main

import "fmt"

type FutureResilienceStatus struct {
	Name                         string
	SystemicRiskCapacity         float64
	GovernanceIntegration        float64
	JusticeTransformation        float64
	RegenerativeCapacity         float64
	LocalCapability              float64
	TechnologicalAccountability  float64
	PlanetaryAlignment           float64
	InvestmentReadiness          float64
	FragmentationRisk            float64
	MaladaptationRisk            float64
	InequalityRisk               float64
	EcologicalOvershootRisk      float64
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

func futureResilience(status FutureResilienceStatus) float64 {
	score := 0.13*status.SystemicRiskCapacity +
		0.12*status.GovernanceIntegration +
		0.11*status.JusticeTransformation +
		0.11*status.RegenerativeCapacity +
		0.09*status.LocalCapability +
		0.09*status.TechnologicalAccountability +
		0.09*status.PlanetaryAlignment +
		0.07*status.InvestmentReadiness -
		0.06*status.FragmentationRisk -
		0.05*status.MaladaptationRisk -
		0.04*status.InequalityRisk -
		0.04*status.EcologicalOvershootRisk

	return clamp01(score)
}

func futureBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong future-oriented resilience framework"
	case score >= 0.60:
		return "Moderate future-oriented resilience framework"
	case score >= 0.40:
		return "Limited future-oriented resilience framework"
	default:
		return "Weak future-oriented resilience framework"
	}
}

func main() {
	status := FutureResilienceStatus{
		Name:                        "Future resilience strategy",
		SystemicRiskCapacity:        0.72,
		GovernanceIntegration:       0.66,
		JusticeTransformation:       0.63,
		RegenerativeCapacity:        0.61,
		LocalCapability:             0.64,
		TechnologicalAccountability: 0.58,
		PlanetaryAlignment:          0.60,
		InvestmentReadiness:         0.57,
		FragmentationRisk:           0.31,
		MaladaptationRisk:           0.28,
		InequalityRisk:              0.34,
		EcologicalOvershootRisk:     0.40,
	}

	score := futureResilience(status)

	fmt.Printf("Strategy: %s\n", status.Name)
	fmt.Printf("Future-oriented resilience score: %.3f\n", score)
	fmt.Printf("Readiness band: %s\n", futureBand(score))
}

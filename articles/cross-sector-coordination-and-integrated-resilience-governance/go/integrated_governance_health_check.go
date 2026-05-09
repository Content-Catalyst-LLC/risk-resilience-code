package main

import "fmt"

type IntegratedGovernanceStatus struct {
	Name                     string
	CrossSectorCoordination  float64
	DependencyVisibility    float64
	GovernanceIntegration   float64
	DataInteroperability    float64
	PublicAccountability    float64
	JusticeEquity           float64
	LocalCapability         float64
	AdaptiveLearning        float64
	FragmentationRisk       float64
	MandateConflict         float64
	GovernanceDataGap       float64
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

func integratedGovernanceCapacity(status IntegratedGovernanceStatus) float64 {
	score := 0.15*status.CrossSectorCoordination +
		0.13*status.DependencyVisibility +
		0.12*status.GovernanceIntegration +
		0.10*status.DataInteroperability +
		0.10*status.PublicAccountability +
		0.09*status.JusticeEquity +
		0.08*status.LocalCapability +
		0.08*status.AdaptiveLearning -
		0.06*status.FragmentationRisk -
		0.05*status.MandateConflict -
		0.04*status.GovernanceDataGap

	return clamp01(score)
}

func governanceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong integrated resilience governance capacity"
	case score >= 0.60:
		return "Moderate integrated resilience governance capacity"
	case score >= 0.40:
		return "Limited integrated resilience governance capacity"
	default:
		return "Weak integrated resilience governance capacity"
	}
}

func main() {
	status := IntegratedGovernanceStatus{
		Name:                    "Regional integrated resilience governance system",
		CrossSectorCoordination: 0.70,
		DependencyVisibility:   0.64,
		GovernanceIntegration:  0.66,
		DataInteroperability:   0.61,
		PublicAccountability:   0.63,
		JusticeEquity:          0.62,
		LocalCapability:        0.68,
		AdaptiveLearning:       0.60,
		FragmentationRisk:      0.31,
		MandateConflict:        0.28,
		GovernanceDataGap:      0.30,
	}

	score := integratedGovernanceCapacity(status)

	fmt.Printf("Governance system: %s\n", status.Name)
	fmt.Printf("Integrated governance capacity score: %.3f\n", score)
	fmt.Printf("Readiness band: %s\n", governanceBand(score))
}

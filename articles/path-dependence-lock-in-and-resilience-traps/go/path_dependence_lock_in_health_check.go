package main

import "fmt"

type LockInStatus struct {
	Name                         string
	SunkCost                     float64
	InfrastructureRigidity       float64
	InstitutionalInertia         float64
	IncumbentPower               float64
	SocialDependence             float64
	TechnologicalIncompatibility float64
	EcologicalFeedback           float64
	AlternativeCapacity          float64
	AdaptiveGovernance           float64
	PublicLegitimacy             float64
	JusticeTransition            float64
	Reversibility                float64
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

func lockInPressure(status LockInStatus) float64 {
	return clamp01(
		0.16*status.SunkCost +
			0.16*status.InfrastructureRigidity +
			0.16*status.InstitutionalInertia +
			0.16*status.IncumbentPower +
			0.14*status.SocialDependence +
			0.11*status.TechnologicalIncompatibility +
			0.11*status.EcologicalFeedback,
	)
}

func transformationCapacity(status LockInStatus) float64 {
	return clamp01(
		0.22*status.AlternativeCapacity +
			0.22*status.AdaptiveGovernance +
			0.18*status.PublicLegitimacy +
			0.20*status.JusticeTransition +
			0.18*status.Reversibility,
	)
}

func trapBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Severe resilience trap risk"
	case score >= 0.60:
		return "High resilience trap risk"
	case score >= 0.40:
		return "Moderate resilience trap risk"
	default:
		return "Lower resilience trap risk"
	}
}

func main() {
	status := LockInStatus{
		Name:                         "Carbon-intensive infrastructure pathway",
		SunkCost:                     0.88,
		InfrastructureRigidity:       0.84,
		InstitutionalInertia:         0.76,
		IncumbentPower:               0.82,
		SocialDependence:             0.72,
		TechnologicalIncompatibility: 0.64,
		EcologicalFeedback:           0.58,
		AlternativeCapacity:          0.46,
		AdaptiveGovernance:           0.50,
		PublicLegitimacy:             0.54,
		JusticeTransition:            0.44,
		Reversibility:                0.36,
	}

	pressure := lockInPressure(status)
	capacity := transformationCapacity(status)
	trapRisk := clamp01(0.72*pressure - 0.28*capacity)
	readiness := clamp01(0.68*capacity - 0.32*pressure)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Lock-in pressure score: %.3f\n", pressure)
	fmt.Printf("Transformation capacity score: %.3f\n", capacity)
	fmt.Printf("Resilience trap risk score: %.3f\n", trapRisk)
	fmt.Printf("Transformation readiness score: %.3f\n", readiness)
	fmt.Printf("Escape gap: %.3f\n", capacity-pressure)
	fmt.Printf("Trap band: %s\n", trapBand(trapRisk))
}

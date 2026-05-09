package main

import "fmt"

type SystemicRiskStatus struct {
	Name                    string
	HazardSeverity          float64
	Exposure                float64
	Vulnerability           float64
	Connectivity            float64
	BehavioralAmplification float64
	Capacity                float64
	Modularity              float64
	Governance              float64
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

func systemicRiskPressure(status SystemicRiskStatus) float64 {
	score := 0.16*status.HazardSeverity +
		0.15*status.Exposure +
		0.16*status.Vulnerability +
		0.14*status.Connectivity +
		0.14*status.BehavioralAmplification -
		0.10*status.Capacity -
		0.08*status.Modularity -
		0.07*status.Governance

	return clamp01(score)
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme systemic-risk pressure"
	case score >= 0.60:
		return "High systemic-risk pressure"
	case score >= 0.40:
		return "Moderate systemic-risk pressure"
	default:
		return "Lower systemic-risk pressure"
	}
}

func main() {
	status := SystemicRiskStatus{
		Name:                    "Interdependent Public Services Network",
		HazardSeverity:          0.82,
		Exposure:                0.70,
		Vulnerability:           0.63,
		Connectivity:            0.74,
		BehavioralAmplification: 0.58,
		Capacity:                0.62,
		Modularity:              0.55,
		Governance:              0.60,
	}

	score := systemicRiskPressure(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Systemic-risk pressure: %.3f\n", score)
	fmt.Printf("Risk band: %s\n", riskBand(score))
}

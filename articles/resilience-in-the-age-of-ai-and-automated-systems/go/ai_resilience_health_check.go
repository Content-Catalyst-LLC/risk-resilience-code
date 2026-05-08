package main

import "fmt"

type AIStatus struct {
	Name                 string
	ResilienceCapacity   float64
	AutomationFragility  float64
	ServiceCriticality    float64
	PublicAccountability  float64
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme AI resilience risk"
	case score >= 0.60:
		return "High AI resilience risk"
	case score >= 0.40:
		return "Moderate AI resilience risk"
	default:
		return "Lower AI resilience risk"
	}
}

func resilienceAdjustedRisk(system AIStatus) float64 {
	score := 0.36*system.AutomationFragility +
		0.22*(1-system.ResilienceCapacity) +
		0.22*system.ServiceCriticality +
		0.20*(1-system.PublicAccountability)

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	system := AIStatus{
		Name:                 "Public Services Eligibility Model",
		ResilienceCapacity:   0.62,
		AutomationFragility:  0.54,
		ServiceCriticality:   0.88,
		PublicAccountability: 0.57,
	}

	score := resilienceAdjustedRisk(system)

	fmt.Printf("AI system: %s\n", system.Name)
	fmt.Printf("Resilience-adjusted AI risk: %.3f\n", score)
	fmt.Printf("Risk band: %s\n", riskBand(score))
}

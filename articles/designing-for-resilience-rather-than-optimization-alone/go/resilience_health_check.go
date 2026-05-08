package main

import "fmt"

type SystemStatus struct {
	Name               string
	OptimizationRisk   float64
	ResilienceCapacity float64
	ServiceCriticality  float64
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme resilience-design risk"
	case score >= 0.60:
		return "High resilience-design risk"
	case score >= 0.40:
		return "Moderate resilience-design risk"
	default:
		return "Lower resilience-design risk"
	}
}

func resilienceAdjustedRisk(system SystemStatus) float64 {
	score := 0.45*system.OptimizationRisk +
		0.35*(1-system.ResilienceCapacity) +
		0.20*system.ServiceCriticality

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	system := SystemStatus{
		Name:               "Regional Water System",
		OptimizationRisk:   0.72,
		ResilienceCapacity: 0.48,
		ServiceCriticality:  0.95,
	}

	score := resilienceAdjustedRisk(system)

	fmt.Printf("System: %s\n", system.Name)
	fmt.Printf("Resilience-adjusted risk: %.3f\n", score)
	fmt.Printf("Risk band: %s\n", riskBand(score))
}

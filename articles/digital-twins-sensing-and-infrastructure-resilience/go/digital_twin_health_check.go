package main

import "fmt"

type TwinStatus struct {
	Name                   string
	ResilienceContribution float64
	ImplementationRisk     float64
	ServiceContinuity       float64
	GovernanceCapacity      float64
}

func readinessBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong digital twin resilience readiness"
	case score >= 0.60:
		return "Moderate digital twin resilience readiness"
	case score >= 0.40:
		return "Limited digital twin resilience readiness"
	default:
		return "Weak digital twin resilience readiness"
	}
}

func resilienceReadiness(twin TwinStatus) float64 {
	score := 0.42*twin.ResilienceContribution +
		0.22*(1-twin.ImplementationRisk) +
		0.18*twin.ServiceContinuity +
		0.18*twin.GovernanceCapacity

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	twin := TwinStatus{
		Name:                   "Urban Water Network Twin",
		ResilienceContribution: 0.74,
		ImplementationRisk:     0.31,
		ServiceContinuity:       0.92,
		GovernanceCapacity:      0.68,
	}

	score := resilienceReadiness(twin)

	fmt.Printf("Digital twin: %s\n", twin.Name)
	fmt.Printf("Resilience readiness: %.3f\n", score)
	fmt.Printf("Readiness band: %s\n", readinessBand(score))
}

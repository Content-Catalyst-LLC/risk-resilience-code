package main

import "fmt"

type ScenarioPlanningStatus struct {
	Name                       string
	ScenarioMatrixQuality      float64
	ShockLibraryReliability    float64
	PlanningActionability      float64
	AdaptiveDecisionCapacity   float64
	BlindSpotPressure          float64
}

func planningBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong scenario-based resilience planning"
	case score >= 0.60:
		return "Moderate scenario-based resilience planning"
	case score >= 0.40:
		return "Limited scenario-based resilience planning"
	default:
		return "Weak scenario-based resilience planning"
	}
}

func resiliencePlanningReadiness(status ScenarioPlanningStatus) float64 {
	score := 0.28*status.ScenarioMatrixQuality +
		0.24*status.ShockLibraryReliability +
		0.22*status.PlanningActionability +
		0.14*status.AdaptiveDecisionCapacity +
		0.12*(1-status.BlindSpotPressure)

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := ScenarioPlanningStatus{
		Name:                     "Municipal Scenario Matrix and Shock Library",
		ScenarioMatrixQuality:    0.72,
		ShockLibraryReliability:  0.69,
		PlanningActionability:    0.66,
		AdaptiveDecisionCapacity: 0.63,
		BlindSpotPressure:        0.34,
	}

	score := resiliencePlanningReadiness(status)

	fmt.Printf("Planning system: %s\n", status.Name)
	fmt.Printf("Resilience-planning readiness: %.3f\n", score)
	fmt.Printf("Planning band: %s\n", planningBand(score))
}

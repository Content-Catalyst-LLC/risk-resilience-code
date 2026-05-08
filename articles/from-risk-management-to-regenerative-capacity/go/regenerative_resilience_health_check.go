package main

import "fmt"

type RegenerativeStatus struct {
	Name                         string
	DefensiveRiskManagement      float64
	RegenerativeCapacity         float64
	DepletionMaladaptationPressure float64
	JusticeOrientation           float64
	EcologicalFunction           float64
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong regenerative resilience"
	case score >= 0.60:
		return "Moderate regenerative resilience"
	case score >= 0.40:
		return "Limited regenerative resilience"
	default:
		return "Weak regenerative resilience"
	}
}

func regenerativeResilienceScore(status RegenerativeStatus) float64 {
	score := 0.34*status.RegenerativeCapacity +
		0.24*status.DefensiveRiskManagement +
		0.18*(1-status.DepletionMaladaptationPressure) +
		0.12*status.JusticeOrientation +
		0.12*status.EcologicalFunction

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := RegenerativeStatus{
		Name:                         "Watershed and Food-System Renewal Program",
		DefensiveRiskManagement:      0.70,
		RegenerativeCapacity:         0.66,
		DepletionMaladaptationPressure: 0.39,
		JusticeOrientation:           0.64,
		EcologicalFunction:           0.62,
	}

	score := regenerativeResilienceScore(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Regenerative resilience score: %.3f\n", score)
	fmt.Printf("Resilience band: %s\n", resilienceBand(score))
}

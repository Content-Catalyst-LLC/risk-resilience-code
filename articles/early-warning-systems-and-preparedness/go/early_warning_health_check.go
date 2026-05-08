package main

import "fmt"

type WarningStatus struct {
	Name                 string
	WarningEffectiveness float64
	PreparednessSystem   float64
	WarningVulnerability float64
	EquityAccess         float64
}

func readinessBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong early warning and preparedness readiness"
	case score >= 0.60:
		return "Moderate early warning and preparedness readiness"
	case score >= 0.40:
		return "Limited early warning and preparedness readiness"
	default:
		return "Weak early warning and preparedness readiness"
	}
}

func earlyActionReadiness(status WarningStatus) float64 {
	score := 0.38*status.WarningEffectiveness +
		0.32*status.PreparednessSystem +
		0.18*(1-status.WarningVulnerability) +
		0.12*status.EquityAccess

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := WarningStatus{
		Name:                 "Regional Flood Warning System",
		WarningEffectiveness: 0.73,
		PreparednessSystem:   0.66,
		WarningVulnerability: 0.39,
		EquityAccess:         0.64,
	}

	score := earlyActionReadiness(status)

	fmt.Printf("Warning system: %s\n", status.Name)
	fmt.Printf("Early action readiness score: %.3f\n", score)
	fmt.Printf("Readiness band: %s\n", readinessBand(score))
}

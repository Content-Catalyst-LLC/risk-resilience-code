package main

import "fmt"

type InstitutionStatus struct {
	Name                  string
	StressReadiness       float64
	StressVulnerability   float64
	InstitutionalRecovery float64
	EquityProtection      float64
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme public-institution stress risk"
	case score >= 0.60:
		return "High public-institution stress risk"
	case score >= 0.40:
		return "Moderate public-institution stress risk"
	default:
		return "Lower public-institution stress risk"
	}
}

func resilienceAdjustedStressRisk(status InstitutionStatus) float64 {
	score := 0.36*status.StressVulnerability +
		0.24*(1-status.StressReadiness) +
		0.18*(1-status.InstitutionalRecovery) +
		0.22*(1-status.EquityProtection)

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := InstitutionStatus{
		Name:                  "Public Benefits Continuity System",
		StressReadiness:       0.66,
		StressVulnerability:   0.47,
		InstitutionalRecovery: 0.62,
		EquityProtection:      0.59,
	}

	score := resilienceAdjustedStressRisk(status)

	fmt.Printf("Institution/system: %s\n", status.Name)
	fmt.Printf("Resilience-adjusted stress risk: %.3f\n", score)
	fmt.Printf("Risk band: %s\n", riskBand(score))
}

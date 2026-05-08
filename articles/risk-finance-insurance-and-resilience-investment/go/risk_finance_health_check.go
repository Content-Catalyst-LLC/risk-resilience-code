package main

import "fmt"

type FinanceStatus struct {
	Name                       string
	ResilienceFinanceCapacity float64
	ProtectionGapPressure     float64
	RiskVisibilityGovernance   float64
	SystemicTransmissionRisk   float64
	DebtStress                 float64
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Extreme resilience finance risk"
	case score >= 0.60:
		return "High resilience finance risk"
	case score >= 0.40:
		return "Moderate resilience finance risk"
	default:
		return "Lower resilience finance risk"
	}
}

func resilienceAdjustedFinancialRisk(status FinanceStatus) float64 {
	score := 0.34*status.ProtectionGapPressure +
		0.24*(1-status.ResilienceFinanceCapacity) +
		0.16*(1-status.RiskVisibilityGovernance) +
		0.14*status.SystemicTransmissionRisk +
		0.12*status.DebtStress

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := FinanceStatus{
		Name:                       "Coastal Flood Risk Finance Portfolio",
		ResilienceFinanceCapacity: 0.66,
		ProtectionGapPressure:     0.52,
		RiskVisibilityGovernance:   0.63,
		SystemicTransmissionRisk:   0.48,
		DebtStress:                 0.41,
	}

	score := resilienceAdjustedFinancialRisk(status)

	fmt.Printf("Risk finance system: %s\n", status.Name)
	fmt.Printf("Resilience-adjusted financial risk: %.3f\n", score)
	fmt.Printf("Risk band: %s\n", riskBand(score))
}

package main

import "fmt"

type IndicatorStatus struct {
	Name                     string
	CapacityAssetProcess     float64
	PerformanceOutcome       float64
	MeasurementVulnerability float64
	EquityProtection         float64
	FinancialProtection      float64
	DistributionalInequality float64
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong equity-adjusted measured resilience"
	case score >= 0.60:
		return "Moderate equity-adjusted measured resilience"
	case score >= 0.40:
		return "Limited equity-adjusted measured resilience"
	default:
		return "Weak equity-adjusted measured resilience"
	}
}

func equityAdjustedResilience(status IndicatorStatus) float64 {
	measured := 0.30*status.CapacityAssetProcess +
		0.30*status.PerformanceOutcome +
		0.16*status.EquityProtection +
		0.12*status.FinancialProtection +
		0.12*(1-status.MeasurementVulnerability)

	score := measured -
		0.25*status.DistributionalInequality -
		0.15*(1-status.EquityProtection)

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := IndicatorStatus{
		Name:                     "Urban Resilience Indicator System",
		CapacityAssetProcess:     0.70,
		PerformanceOutcome:       0.66,
		MeasurementVulnerability: 0.34,
		EquityProtection:         0.62,
		FinancialProtection:      0.59,
		DistributionalInequality: 0.31,
	}

	score := equityAdjustedResilience(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Equity-adjusted measured resilience: %.3f\n", score)
	fmt.Printf("Resilience band: %s\n", resilienceBand(score))
}

package main

import "fmt"

type DataTrustStatus struct {
	Name                         string
	ProvenanceStrength           float64
	AuditabilityStrength         float64
	EthicalGovernance            float64
	DataQuality                  float64
	DataRiskPressure             float64
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

func resilienceDataTrust(status DataTrustStatus) float64 {
	score := 0.30*status.ProvenanceStrength +
		0.26*status.AuditabilityStrength +
		0.20*status.EthicalGovernance +
		0.14*status.DataQuality +
		0.10*(1-status.DataRiskPressure)

	return clamp01(score)
}

func trustBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong resilience data trust"
	case score >= 0.60:
		return "Moderate resilience data trust"
	case score >= 0.40:
		return "Limited resilience data trust"
	default:
		return "Weak resilience data trust"
	}
}

func main() {
	status := DataTrustStatus{
		Name:                 "Public Resilience Dashboard Dataset",
		ProvenanceStrength:   0.72,
		AuditabilityStrength: 0.68,
		EthicalGovernance:    0.70,
		DataQuality:          0.74,
		DataRiskPressure:     0.29,
	}

	score := resilienceDataTrust(status)

	fmt.Printf("Dataset: %s\n", status.Name)
	fmt.Printf("Resilience data trust score: %.3f\n", score)
	fmt.Printf("Trust band: %s\n", trustBand(score))
}

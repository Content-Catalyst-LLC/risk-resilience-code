package main

import "fmt"

type GovernanceStatus struct {
	Name                              string
	ResilienceGovernanceQuality       float64
	AccountabilityLegitimacyCapacity   float64
	GovernanceVulnerability           float64
	JusticeOrientation                float64
}

func governanceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong legitimate resilience governance"
	case score >= 0.60:
		return "Moderate legitimate resilience governance"
	case score >= 0.40:
		return "Limited legitimate resilience governance"
	default:
		return "Weak legitimate resilience governance"
	}
}

func legitimateResilienceGovernanceScore(status GovernanceStatus) float64 {
	score := 0.38*status.ResilienceGovernanceQuality +
		0.32*status.AccountabilityLegitimacyCapacity +
		0.18*(1-status.GovernanceVulnerability) +
		0.12*status.JusticeOrientation

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := GovernanceStatus{
		Name:                            "Regional Resilience Governance System",
		ResilienceGovernanceQuality:     0.72,
		AccountabilityLegitimacyCapacity: 0.68,
		GovernanceVulnerability:         0.37,
		JusticeOrientation:              0.66,
	}

	score := legitimateResilienceGovernanceScore(status)

	fmt.Printf("Institution/system: %s\n", status.Name)
	fmt.Printf("Legitimate resilience governance score: %.3f\n", score)
	fmt.Printf("Governance band: %s\n", governanceBand(score))
}

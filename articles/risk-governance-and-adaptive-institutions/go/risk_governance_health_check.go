package main

import "fmt"

type GovernanceStatus struct {
	Name                    string
	RiskGovernanceQuality   float64
	AdaptiveCapacity        float64
	GovernanceVulnerability float64
	JusticeOrientation      float64
}

func governanceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong adaptive risk governance"
	case score >= 0.60:
		return "Moderate adaptive risk governance"
	case score >= 0.40:
		return "Limited adaptive risk governance"
	default:
		return "Weak adaptive risk governance"
	}
}

func resilienceGovernanceScore(status GovernanceStatus) float64 {
	score := 0.40*status.RiskGovernanceQuality +
		0.32*status.AdaptiveCapacity +
		0.18*(1-status.GovernanceVulnerability) +
		0.10*status.JusticeOrientation

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
		Name:                    "Regional Climate Risk Governance System",
		RiskGovernanceQuality:   0.71,
		AdaptiveCapacity:        0.66,
		GovernanceVulnerability: 0.38,
		JusticeOrientation:      0.64,
	}

	score := resilienceGovernanceScore(status)

	fmt.Printf("Institution/system: %s\n", status.Name)
	fmt.Printf("Resilience governance score: %.3f\n", score)
	fmt.Printf("Governance band: %s\n", governanceBand(score))
}

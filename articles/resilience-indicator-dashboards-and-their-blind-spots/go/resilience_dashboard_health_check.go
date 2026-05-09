package main

import "fmt"

type DashboardStatus struct {
	Name                         string
	DashboardStrength            float64
	BlindSpotRisk                float64
	DashboardActionability       float64
	EquityVisibility             float64
	CommunityValidation          float64
}

func dashboardBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong resilience dashboard reliability"
	case score >= 0.60:
		return "Moderate resilience dashboard reliability"
	case score >= 0.40:
		return "Limited resilience dashboard reliability"
	default:
		return "Weak resilience dashboard reliability"
	}
}

func equityAdjustedDashboardReliability(status DashboardStatus) float64 {
	score := 0.34*status.DashboardStrength +
		0.24*status.DashboardActionability +
		0.18*(1-status.BlindSpotRisk) +
		0.14*status.EquityVisibility +
		0.10*status.CommunityValidation

	if score < 0 {
		return 0
	}

	if score > 1 {
		return 1
	}

	return score
}

func main() {
	status := DashboardStatus{
		Name:                   "City Resilience Indicator Dashboard",
		DashboardStrength:      0.71,
		BlindSpotRisk:          0.38,
		DashboardActionability: 0.66,
		EquityVisibility:       0.62,
		CommunityValidation:    0.55,
	}

	score := equityAdjustedDashboardReliability(status)

	fmt.Printf("Dashboard: %s\n", status.Name)
	fmt.Printf("Equity-adjusted dashboard reliability: %.3f\n", score)
	fmt.Printf("Dashboard band: %s\n", dashboardBand(score))
}

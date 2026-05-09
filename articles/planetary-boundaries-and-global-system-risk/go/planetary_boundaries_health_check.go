package main

import "fmt"

type BoundaryStatus struct {
	Name                    string
	BoundaryTransgression   float64
	PressureTrend           float64
	InteractionStrength     float64
	ReversibilityRisk       float64
	HumanSystemExposure     float64
	MonitoringConfidence    float64
	AdaptiveCapacity        float64
	GovernanceQuality       float64
	JusticeTransition       float64
	PolicyResponse          float64
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

func planetaryPressure(status BoundaryStatus) float64 {
	return clamp01(
		0.26*status.BoundaryTransgression +
			0.22*status.PressureTrend +
			0.20*status.InteractionStrength +
			0.18*status.ReversibilityRisk +
			0.14*status.HumanSystemExposure,
	)
}

func responseCapacity(status BoundaryStatus) float64 {
	return clamp01(
		0.20*status.MonitoringConfidence +
			0.22*status.AdaptiveCapacity +
			0.22*status.GovernanceQuality +
			0.18*status.JusticeTransition +
			0.18*status.PolicyResponse,
	)
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Severe planetary system risk"
	case score >= 0.60:
		return "High planetary system risk"
	case score >= 0.40:
		return "Moderate planetary system risk"
	default:
		return "Lower planetary system risk"
	}
}

func main() {
	status := BoundaryStatus{
		Name:                  "Biosphere integrity",
		BoundaryTransgression: 0.92,
		PressureTrend:         0.86,
		InteractionStrength:   0.90,
		ReversibilityRisk:     0.88,
		HumanSystemExposure:   0.84,
		MonitoringConfidence:  0.68,
		AdaptiveCapacity:      0.42,
		GovernanceQuality:     0.38,
		JusticeTransition:     0.36,
		PolicyResponse:        0.40,
	}

	pressure := planetaryPressure(status)
	capacity := responseCapacity(status)
	risk := clamp01(0.74*pressure + 0.18*status.HumanSystemExposure + 0.08*status.ReversibilityRisk - 0.24*capacity)

	fmt.Printf("Boundary: %s\n", status.Name)
	fmt.Printf("Planetary pressure score: %.3f\n", pressure)
	fmt.Printf("Response capacity score: %.3f\n", capacity)
	fmt.Printf("Planetary system risk score: %.3f\n", risk)
	fmt.Printf("Earth-system resilience margin: %.3f\n", capacity-pressure)
	fmt.Printf("Risk band: %s\n", riskBand(risk))
}

package main

import "fmt"

type PolycrisisStatus struct {
	Name                    string
	CrisisIntensity         float64
	InteractionCoupling     float64
	SystemicVulnerability   float64
	FeedbackAmplification   float64
	ThresholdProximity      float64
	InstitutionalCapacity   float64
	PublicLegitimacy        float64
	RegenerativeCapacity    float64
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

func polycrisisPressure(status PolycrisisStatus) float64 {
	score := 0.16*status.CrisisIntensity +
		0.15*status.InteractionCoupling +
		0.16*status.SystemicVulnerability +
		0.14*status.FeedbackAmplification +
		0.13*status.ThresholdProximity -
		0.10*status.InstitutionalCapacity -
		0.08*status.PublicLegitimacy -
		0.08*status.RegenerativeCapacity

	return clamp01(score)
}

func pressureBand(score float64) string {
	switch {
	case score >= 0.75:
		return "Severe polycrisis pressure"
	case score >= 0.55:
		return "High polycrisis pressure"
	case score >= 0.35:
		return "Moderate polycrisis pressure"
	default:
		return "Lower polycrisis pressure"
	}
}

func main() {
	status := PolycrisisStatus{
		Name:                  "Regional polycrisis readiness system",
		CrisisIntensity:       0.74,
		InteractionCoupling:   0.68,
		SystemicVulnerability: 0.72,
		FeedbackAmplification: 0.64,
		ThresholdProximity:    0.60,
		InstitutionalCapacity: 0.58,
		PublicLegitimacy:      0.55,
		RegenerativeCapacity:  0.50,
	}

	score := polycrisisPressure(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Polycrisis pressure: %.3f\n", score)
	fmt.Printf("Pressure band: %s\n", pressureBand(score))
}

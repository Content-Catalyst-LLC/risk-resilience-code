package main

import "fmt"

type ShockPropagationStatus struct {
	Name                  string
	ShockIntensity        float64
	ThresholdProximity    float64
	NetworkCentrality     float64
	CouplingStrength      float64
	FeedbackAmplification float64
	HiddenStress          float64
	ExposureInequality    float64
	BufferingCapacity     float64
	Modularity            float64
	Redundancy            float64
	AdaptiveResponse      float64
	GovernanceQuality     float64
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

func propagationPressure(status ShockPropagationStatus) float64 {
	return clamp01(
		0.16*status.ShockIntensity +
			0.18*status.ThresholdProximity +
			0.16*status.NetworkCentrality +
			0.16*status.CouplingStrength +
			0.14*status.FeedbackAmplification +
			0.10*status.HiddenStress +
			0.10*status.ExposureInequality,
	)
}

func containmentCapacity(status ShockPropagationStatus) float64 {
	return clamp01(
		0.22*status.BufferingCapacity +
			0.20*status.Modularity +
			0.20*status.Redundancy +
			0.20*status.AdaptiveResponse +
			0.18*status.GovernanceQuality,
	)
}

func propagationBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Severe nonlinear propagation risk"
	case score >= 0.60:
		return "High nonlinear propagation risk"
	case score >= 0.40:
		return "Moderate nonlinear propagation risk"
	default:
		return "Lower nonlinear propagation risk"
	}
}

func nonlinearDamage(shockIntensity float64, thresholdProximity float64) float64 {
	if thresholdProximity >= 1.0 {
		return 999.0
	}

	return shockIntensity / (1.0 - thresholdProximity)
}

func main() {
	status := ShockPropagationStatus{
		Name:                  "Interdependent infrastructure corridor",
		ShockIntensity:        0.58,
		ThresholdProximity:    0.80,
		NetworkCentrality:     0.76,
		CouplingStrength:      0.78,
		FeedbackAmplification: 0.70,
		HiddenStress:          0.72,
		ExposureInequality:    0.68,
		BufferingCapacity:     0.44,
		Modularity:            0.46,
		Redundancy:            0.48,
		AdaptiveResponse:      0.50,
		GovernanceQuality:     0.52,
	}

	pressure := propagationPressure(status)
	capacity := containmentCapacity(status)
	risk := clamp01(0.74*pressure - 0.26*capacity)
	damage := nonlinearDamage(status.ShockIntensity, status.ThresholdProximity)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Propagation pressure score: %.3f\n", pressure)
	fmt.Printf("Containment capacity score: %.3f\n", capacity)
	fmt.Printf("Nonlinear propagation risk score: %.3f\n", risk)
	fmt.Printf("Propagation resilience margin: %.3f\n", capacity-pressure)
	fmt.Printf("Nonlinear damage proxy: %.3f\n", damage)
	fmt.Printf("Propagation band: %s\n", propagationBand(risk))
}

package main

import "fmt"

type TightCouplingStatus struct {
	Name                   string
	CouplingStrength       float64
	TimeCompression        float64
	SequenceRigidity       float64
	LimitedSubstitution    float64
	InteractiveComplexity  float64
	HiddenDependency       float64
	CriticalNodeImportance float64
	Buffering              float64
	Modularity             float64
	Redundancy             float64
	AdaptiveAuthority      float64
	FallbackCapacity       float64
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

func tightCouplingPressure(status TightCouplingStatus) float64 {
	return clamp01(
		0.16*status.CouplingStrength +
			0.16*status.TimeCompression +
			0.14*status.SequenceRigidity +
			0.13*status.LimitedSubstitution +
			0.15*status.InteractiveComplexity +
			0.12*status.HiddenDependency +
			0.14*status.CriticalNodeImportance,
	)
}

func resilienceRoom(status TightCouplingStatus) float64 {
	return clamp01(
		0.22*status.Buffering +
			0.20*status.Modularity +
			0.20*status.Redundancy +
			0.20*status.AdaptiveAuthority +
			0.18*status.FallbackCapacity,
	)
}

func failureRiskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Severe tight-coupling catastrophic-failure risk"
	case score >= 0.60:
		return "High tight-coupling catastrophic-failure risk"
	case score >= 0.40:
		return "Moderate tight-coupling catastrophic-failure risk"
	default:
		return "Lower tight-coupling catastrophic-failure risk"
	}
}

func main() {
	status := TightCouplingStatus{
		Name:                   "Automated water-energy-health dependency",
		CouplingStrength:       0.82,
		TimeCompression:        0.80,
		SequenceRigidity:       0.76,
		LimitedSubstitution:    0.72,
		InteractiveComplexity:  0.78,
		HiddenDependency:       0.70,
		CriticalNodeImportance: 0.84,
		Buffering:              0.42,
		Modularity:             0.44,
		Redundancy:             0.48,
		AdaptiveAuthority:      0.46,
		FallbackCapacity:       0.40,
	}

	pressure := tightCouplingPressure(status)
	room := resilienceRoom(status)
	risk := clamp01(0.74*pressure - 0.26*room)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Tight-coupling pressure score: %.3f\n", pressure)
	fmt.Printf("Resilience room score: %.3f\n", room)
	fmt.Printf("Catastrophic-failure risk score: %.3f\n", risk)
	fmt.Printf("Containment margin: %.3f\n", room-pressure)
	fmt.Printf("Failure risk band: %s\n", failureRiskBand(risk))
}

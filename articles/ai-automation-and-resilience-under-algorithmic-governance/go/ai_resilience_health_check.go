package main

import "fmt"

type AIResilienceStatus struct {
	Name                    string
	ModelCapability         float64
	InstitutionalGovernance float64
	DataQuality             float64
	HumanOversight          float64
	SystemRobustness        float64
	Auditability            float64
	OpacityRisk             float64
	BiasSeverity            float64
	ModelDriftRisk          float64
	AutomationDependency    float64
	CyberExposure           float64
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

func algorithmicResilience(status AIResilienceStatus) float64 {
	score := 0.13*status.ModelCapability +
		0.13*status.InstitutionalGovernance +
		0.11*status.DataQuality +
		0.12*status.HumanOversight +
		0.11*status.SystemRobustness +
		0.10*status.Auditability -
		0.08*status.OpacityRisk -
		0.07*status.BiasSeverity -
		0.06*status.ModelDriftRisk -
		0.05*status.AutomationDependency -
		0.04*status.CyberExposure

	return clamp01(score)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong algorithmic resilience readiness"
	case score >= 0.60:
		return "Moderate algorithmic resilience readiness"
	case score >= 0.40:
		return "Limited algorithmic resilience readiness"
	default:
		return "Weak algorithmic resilience readiness"
	}
}

func main() {
	status := AIResilienceStatus{
		Name:                    "Public AI resilience decision-support system",
		ModelCapability:         0.74,
		InstitutionalGovernance: 0.66,
		DataQuality:             0.70,
		HumanOversight:          0.63,
		SystemRobustness:        0.68,
		Auditability:            0.62,
		OpacityRisk:             0.31,
		BiasSeverity:            0.28,
		ModelDriftRisk:          0.34,
		AutomationDependency:    0.40,
		CyberExposure:           0.36,
	}

	score := algorithmicResilience(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Algorithmic resilience score: %.3f\n", score)
	fmt.Printf("Readiness band: %s\n", resilienceBand(score))
}

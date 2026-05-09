package main

import "fmt"

type SystemDesignStatus struct {
	Name                       string
	RoutineEfficiency          float64
	ProtectiveSlack           float64
	Redundancy                float64
	Modularity                float64
	Diversity                 float64
	FeedbackMonitoring        float64
	RepairCapacity            float64
	GovernanceQuality         float64
	TightCoupling             float64
	SinglePointDependence     float64
	Overload                  float64
	DeferredMaintenance       float64
	HiddenRiskTransfer        float64
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

func resilienceCapacity(status SystemDesignStatus) float64 {
	return clamp01(
		0.12*status.RoutineEfficiency +
			0.16*status.ProtectiveSlack +
			0.14*status.Redundancy +
			0.13*status.Modularity +
			0.12*status.Diversity +
			0.12*status.FeedbackMonitoring +
			0.11*status.RepairCapacity +
			0.10*status.GovernanceQuality,
	)
}

func optimizationFragilityPressure(status SystemDesignStatus) float64 {
	return clamp01(
		0.22*status.TightCoupling +
			0.22*status.SinglePointDependence +
			0.20*status.Overload +
			0.18*status.DeferredMaintenance +
			0.18*status.HiddenRiskTransfer,
	)
}

func designBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Resilient efficiency"
	case score >= 0.60:
		return "Moderate resilience-aware performance"
	case score >= 0.40:
		return "Limited resilience-aware performance"
	default:
		return "Fragility-producing optimization"
	}
}

func main() {
	status := SystemDesignStatus{
		Name:                   "Lean critical supply chain",
		RoutineEfficiency:      0.84,
		ProtectiveSlack:       0.42,
		Redundancy:            0.44,
		Modularity:            0.50,
		Diversity:             0.46,
		FeedbackMonitoring:    0.58,
		RepairCapacity:        0.48,
		GovernanceQuality:     0.52,
		TightCoupling:         0.78,
		SinglePointDependence: 0.74,
		Overload:              0.70,
		DeferredMaintenance:   0.58,
		HiddenRiskTransfer:    0.72,
	}

	capacity := resilienceCapacity(status)
	pressure := optimizationFragilityPressure(status)
	performance := clamp01(0.70*capacity - 0.30*pressure)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Resilience capacity score: %.3f\n", capacity)
	fmt.Printf("Optimization fragility pressure score: %.3f\n", pressure)
	fmt.Printf("Resilience-aware performance score: %.3f\n", performance)
	fmt.Printf("Slack-fragility gap: %.3f\n", capacity-pressure)
	fmt.Printf("System design band: %s\n", designBand(performance))
}

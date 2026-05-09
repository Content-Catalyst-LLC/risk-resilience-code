package main

import "fmt"

type DrinkingWaterStatus struct {
	Name                    string
	SourceProtection        float64
	TreatmentCapacity       float64
	DistributionReliability float64
	MonitoringQuality       float64
	SupplyDiversity         float64
	EnergyResilience        float64
	Affordability           float64
	GovernanceCapacity      float64
	ContaminationRisk       float64
	InfrastructureAging     float64
	SalinityPressure        float64
	EnergyDependence        float64
	BrineBurden             float64
	AccessInequality        float64
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

func waterResilienceCapacity(status DrinkingWaterStatus) float64 {
	return clamp01(
		0.15*status.SourceProtection +
			0.16*status.TreatmentCapacity +
			0.15*status.DistributionReliability +
			0.14*status.MonitoringQuality +
			0.11*status.SupplyDiversity +
			0.10*status.EnergyResilience +
			0.09*status.Affordability +
			0.10*status.GovernanceCapacity,
	)
}

func waterRiskPressure(status DrinkingWaterStatus) float64 {
	return clamp01(
		0.22*status.ContaminationRisk +
			0.18*status.InfrastructureAging +
			0.16*status.SalinityPressure +
			0.15*status.EnergyDependence +
			0.13*status.BrineBurden +
			0.16*status.AccessInequality,
	)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong drinking-water resilience"
	case score >= 0.60:
		return "Moderate drinking-water resilience"
	case score >= 0.40:
		return "Limited drinking-water resilience"
	default:
		return "Weak drinking-water resilience"
	}
}

func main() {
	status := DrinkingWaterStatus{
		Name:                    "Coastal desalination and reuse portfolio",
		SourceProtection:        0.68,
		TreatmentCapacity:       0.82,
		DistributionReliability: 0.62,
		MonitoringQuality:       0.70,
		SupplyDiversity:         0.78,
		EnergyResilience:        0.58,
		Affordability:           0.50,
		GovernanceCapacity:      0.66,
		ContaminationRisk:       0.40,
		InfrastructureAging:     0.56,
		SalinityPressure:        0.72,
		EnergyDependence:        0.70,
		BrineBurden:             0.58,
		AccessInequality:        0.52,
	}

	capacity := waterResilienceCapacity(status)
	pressure := waterRiskPressure(status)
	resilience := clamp01(0.72*capacity - 0.28*pressure)

	fmt.Printf("Water system: %s\n", status.Name)
	fmt.Printf("Water resilience capacity score: %.3f\n", capacity)
	fmt.Printf("Water-system risk pressure score: %.3f\n", pressure)
	fmt.Printf("Drinking-water resilience score: %.3f\n", resilience)
	fmt.Printf("Source-to-tap resilience gap: %.3f\n", capacity-pressure)
	fmt.Printf("Resilience band: %s\n", resilienceBand(resilience))
}

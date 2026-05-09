package main

import "fmt"

type EnergySystemStatus struct {
	Name                   string
	Reliability            float64
	Adequacy               float64
	Redundancy             float64
	Flexibility            float64
	DistributedCapacity    float64
	CyberResilience        float64
	RestorationCapacity    float64
	CriticalLoadProtection float64
	Affordability          float64
	EquityProtection       float64
	ClimateExposure        float64
	InfrastructureAging    float64
	FuelDependence         float64
	DigitalFragility       float64
	LoadGrowthPressure     float64
	InterdependencyRisk    float64
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

func energyResilienceCapacity(status EnergySystemStatus) float64 {
	return clamp01(
		0.14*status.Reliability +
			0.13*status.Adequacy +
			0.13*status.Redundancy +
			0.12*status.Flexibility +
			0.11*status.DistributedCapacity +
			0.11*status.CyberResilience +
			0.13*status.RestorationCapacity +
			0.13*status.CriticalLoadProtection,
	)
}

func gridFragilityPressure(status EnergySystemStatus) float64 {
	return clamp01(
		0.18*status.ClimateExposure +
			0.17*status.InfrastructureAging +
			0.15*status.FuelDependence +
			0.15*status.DigitalFragility +
			0.18*status.LoadGrowthPressure +
			0.17*status.InterdependencyRisk,
	)
}

func justEnergyResilience(status EnergySystemStatus) float64 {
	return clamp01(
		0.24*status.Affordability +
			0.24*status.EquityProtection +
			0.22*status.CriticalLoadProtection +
			0.16*status.DistributedCapacity +
			0.14*status.RestorationCapacity,
	)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong energy security resilience"
	case score >= 0.60:
		return "Moderate energy security resilience"
	case score >= 0.40:
		return "Limited energy security resilience"
	default:
		return "Weak energy security resilience"
	}
}

func main() {
	status := EnergySystemStatus{
		Name:                   "Climate-stressed regional grid",
		Reliability:            0.72,
		Adequacy:               0.68,
		Redundancy:             0.58,
		Flexibility:            0.62,
		DistributedCapacity:    0.54,
		CyberResilience:        0.60,
		RestorationCapacity:    0.66,
		CriticalLoadProtection: 0.64,
		Affordability:          0.50,
		EquityProtection:       0.46,
		ClimateExposure:        0.76,
		InfrastructureAging:    0.64,
		FuelDependence:         0.48,
		DigitalFragility:       0.58,
		LoadGrowthPressure:     0.70,
		InterdependencyRisk:    0.72,
	}

	capacity := energyResilienceCapacity(status)
	fragility := gridFragilityPressure(status)
	justice := justEnergyResilience(status)
	overall := clamp01(0.58*capacity + 0.22*justice - 0.28*fragility)

	fmt.Printf("Energy system: %s\n", status.Name)
	fmt.Printf("Energy resilience capacity score: %.3f\n", capacity)
	fmt.Printf("Grid fragility pressure score: %.3f\n", fragility)
	fmt.Printf("Just energy resilience score: %.3f\n", justice)
	fmt.Printf("Energy-security resilience score: %.3f\n", overall)
	fmt.Printf("Resilience-fragility gap: %.3f\n", capacity-fragility)
	fmt.Printf("Resilience band: %s\n", resilienceBand(overall))
}

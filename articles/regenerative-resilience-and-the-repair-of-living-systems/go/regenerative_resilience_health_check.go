package main

import "fmt"

type RegenerativeResilienceStatus struct {
	Name                     string
	EcosystemIntegrity       float64
	Biodiversity             float64
	SoilHealth               float64
	WaterFunction            float64
	Connectivity             float64
	LocalStewardship         float64
	GovernanceAccountability float64
	JusticeRepair            float64
	DegradationPressure      float64
	FragmentationPressure    float64
	ExtractionPressure       float64
	MaladaptationRisk        float64
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

func regenerativeResilience(status RegenerativeResilienceStatus) float64 {
	score := 0.13*status.EcosystemIntegrity +
		0.12*status.Biodiversity +
		0.12*status.SoilHealth +
		0.11*status.WaterFunction +
		0.10*status.Connectivity +
		0.09*status.LocalStewardship +
		0.09*status.GovernanceAccountability +
		0.08*status.JusticeRepair -
		0.06*status.DegradationPressure -
		0.04*status.FragmentationPressure -
		0.03*status.ExtractionPressure -
		0.03*status.MaladaptationRisk

	return clamp01(score)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong regenerative resilience"
	case score >= 0.60:
		return "Moderate regenerative resilience"
	case score >= 0.40:
		return "Limited regenerative resilience"
	default:
		return "Weak regenerative resilience"
	}
}

func main() {
	status := RegenerativeResilienceStatus{
		Name:                     "Watershed restoration and living-systems repair zone",
		EcosystemIntegrity:       0.68,
		Biodiversity:             0.70,
		SoilHealth:               0.66,
		WaterFunction:            0.63,
		Connectivity:             0.61,
		LocalStewardship:         0.64,
		GovernanceAccountability: 0.58,
		JusticeRepair:            0.55,
		DegradationPressure:      0.36,
		FragmentationPressure:    0.34,
		ExtractionPressure:       0.30,
		MaladaptationRisk:        0.28,
	}

	score := regenerativeResilience(status)

	fmt.Printf("System: %s\n", status.Name)
	fmt.Printf("Regenerative resilience score: %.3f\n", score)
	fmt.Printf("Resilience band: %s\n", resilienceBand(score))
}

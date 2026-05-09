package main

import "fmt"

type BiodiversityResilienceStatus struct {
	Name                    string
	GeneticDiversity        float64
	SpeciesDiversity        float64
	FunctionalDiversity     float64
	HabitatConnectivity     float64
	EcosystemIntegrity      float64
	AdaptiveCapacity        float64
	FragmentationPressure   float64
	PollutionPressure       float64
	InvasivePressure        float64
	ExtractionPressure      float64
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

func biodiversityResilience(status BiodiversityResilienceStatus) float64 {
	score := 0.14*status.GeneticDiversity +
		0.15*status.SpeciesDiversity +
		0.16*status.FunctionalDiversity +
		0.14*status.HabitatConnectivity +
		0.14*status.EcosystemIntegrity +
		0.10*status.AdaptiveCapacity -
		0.07*status.FragmentationPressure -
		0.04*status.PollutionPressure -
		0.03*status.InvasivePressure -
		0.03*status.ExtractionPressure

	return clamp01(score)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong biodiversity-supported resilience"
	case score >= 0.60:
		return "Moderate biodiversity-supported resilience"
	case score >= 0.40:
		return "Limited biodiversity-supported resilience"
	default:
		return "Weak biodiversity-supported resilience"
	}
}

func main() {
	status := BiodiversityResilienceStatus{
		Name:                  "Watershed forest-wetland mosaic",
		GeneticDiversity:      0.70,
		SpeciesDiversity:      0.74,
		FunctionalDiversity:   0.69,
		HabitatConnectivity:   0.63,
		EcosystemIntegrity:    0.66,
		AdaptiveCapacity:      0.61,
		FragmentationPressure: 0.34,
		PollutionPressure:     0.28,
		InvasivePressure:      0.25,
		ExtractionPressure:    0.31,
	}

	score := biodiversityResilience(status)

	fmt.Printf("Ecosystem: %s\n", status.Name)
	fmt.Printf("Biodiversity-supported resilience score: %.3f\n", score)
	fmt.Printf("Resilience band: %s\n", resilienceBand(score))
}

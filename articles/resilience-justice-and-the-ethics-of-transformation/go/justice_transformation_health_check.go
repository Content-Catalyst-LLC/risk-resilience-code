package main

import "fmt"

type JusticeTransformationStatus struct {
	Name                          string
	DistributiveJustice           float64
	ProceduralJustice             float64
	Recognition                   float64
	RightsProtection              float64
	InstitutionalAccountability   float64
	EcologicalGovernance          float64
	IntergenerationalResponsibility float64
	MaladaptationRisk             float64
	HarmShiftingRisk              float64
	ExclusionRisk                 float64
	CoercionRisk                  float64
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

func justiceOrientedTransformation(status JusticeTransformationStatus) float64 {
	score := 0.15*status.DistributiveJustice +
		0.14*status.ProceduralJustice +
		0.12*status.Recognition +
		0.12*status.RightsProtection +
		0.11*status.InstitutionalAccountability +
		0.10*status.EcologicalGovernance +
		0.09*status.IntergenerationalResponsibility -
		0.08*status.MaladaptationRisk -
		0.05*status.HarmShiftingRisk -
		0.03*status.ExclusionRisk -
		0.01*status.CoercionRisk

	return clamp01(score)
}

func justiceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong justice-oriented transformation"
	case score >= 0.60:
		return "Moderate justice-oriented transformation"
	case score >= 0.40:
		return "Limited justice-oriented transformation"
	default:
		return "Weak justice-oriented transformation"
	}
}

func main() {
	status := JusticeTransformationStatus{
		Name:                            "Climate adaptation and relocation initiative",
		DistributiveJustice:             0.68,
		ProceduralJustice:               0.64,
		Recognition:                     0.61,
		RightsProtection:                0.66,
		InstitutionalAccountability:     0.62,
		EcologicalGovernance:            0.58,
		IntergenerationalResponsibility: 0.60,
		MaladaptationRisk:               0.30,
		HarmShiftingRisk:                0.28,
		ExclusionRisk:                   0.25,
		CoercionRisk:                    0.22,
	}

	score := justiceOrientedTransformation(status)

	fmt.Printf("Initiative: %s\n", status.Name)
	fmt.Printf("Justice-oriented transformation score: %.3f\n", score)
	fmt.Printf("Justice band: %s\n", justiceBand(score))
}

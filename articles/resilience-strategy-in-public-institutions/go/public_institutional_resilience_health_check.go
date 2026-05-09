package main

import "fmt"

type PublicInstitutionStatus struct {
	Name                    string
	AnticipatoryForesight   float64
	ContinuityOperations    float64
	AdministrativeCapacity  float64
	CoordinationCapacity    float64
	RiskInformedFinance     float64
	ProcurementResilience   float64
	DigitalFallback         float64
	PublicLegitimacy        float64
	JusticeServiceEquity    float64
	LearningAdaptation      float64
	FragmentationRisk       float64
	UnderinvestmentRisk     float64
	StaffingFragility       float64
	DigitalDependencyRisk   float64
	AccountabilityGap       float64
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

func institutionalResilience(status PublicInstitutionStatus) float64 {
	score := 0.12*status.AnticipatoryForesight +
		0.12*status.ContinuityOperations +
		0.11*status.AdministrativeCapacity +
		0.10*status.CoordinationCapacity +
		0.09*status.RiskInformedFinance +
		0.09*status.ProcurementResilience +
		0.07*status.DigitalFallback +
		0.07*status.PublicLegitimacy +
		0.07*status.JusticeServiceEquity +
		0.06*status.LearningAdaptation -
		0.04*status.FragmentationRisk -
		0.04*status.UnderinvestmentRisk -
		0.03*status.StaffingFragility -
		0.03*status.DigitalDependencyRisk -
		0.02*status.AccountabilityGap

	return clamp01(score)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong public institutional resilience"
	case score >= 0.60:
		return "Moderate public institutional resilience"
	case score >= 0.40:
		return "Limited public institutional resilience"
	default:
		return "Weak public institutional resilience"
	}
}

func main() {
	status := PublicInstitutionStatus{
		Name:                   "Public institutional resilience program",
		AnticipatoryForesight:  0.68,
		ContinuityOperations:   0.72,
		AdministrativeCapacity: 0.65,
		CoordinationCapacity:   0.63,
		RiskInformedFinance:    0.60,
		ProcurementResilience:  0.58,
		DigitalFallback:        0.61,
		PublicLegitimacy:       0.66,
		JusticeServiceEquity:   0.64,
		LearningAdaptation:     0.62,
		FragmentationRisk:      0.30,
		UnderinvestmentRisk:    0.34,
		StaffingFragility:      0.32,
		DigitalDependencyRisk:  0.36,
		AccountabilityGap:      0.28,
	}

	score := institutionalResilience(status)

	fmt.Printf("Institution: %s\n", status.Name)
	fmt.Printf("Public institutional resilience score: %.3f\n", score)
	fmt.Printf("Resilience band: %s\n", resilienceBand(score))
}

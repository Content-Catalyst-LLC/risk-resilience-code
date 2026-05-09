package main

import "fmt"

type UrbanRiskStatus struct {
	Name                    string
	FloodExposure           float64
	HeatExposure            float64
	LandslideOrFireExposure float64
	HousingVulnerability    float64
	InfrastructureDeficit   float64
	ServiceAccess           float64
	TenureSecurity          float64
	LivelihoodPrecarity     float64
	SocialProtectionAccess  float64
	CommunityAdaptation     float64
	InstitutionalProtection float64
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

func riskExposure(status UrbanRiskStatus) float64 {
	hazardExposure := 0.38*status.FloodExposure +
		0.34*status.HeatExposure +
		0.28*status.LandslideOrFireExposure

	vulnerability := 0.24*status.HousingVulnerability +
		0.22*status.InfrastructureDeficit +
		0.18*status.LivelihoodPrecarity +
		0.14*(1-status.TenureSecurity) +
		0.10*(1-status.SocialProtectionAccess)

	return clamp01(0.45*hazardExposure + 0.35*vulnerability + 0.20*status.InfrastructureDeficit)
}

func protectionCapacity(status UrbanRiskStatus) float64 {
	return clamp01(
		0.20*status.ServiceAccess +
			0.18*status.TenureSecurity +
			0.18*status.CommunityAdaptation +
			0.17*status.InstitutionalProtection +
			0.15*status.SocialProtectionAccess +
			0.12*(1-status.InfrastructureDeficit),
	)
}

func riskBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Severe urban risk exposure"
	case score >= 0.60:
		return "High urban risk exposure"
	case score >= 0.40:
		return "Moderate urban risk exposure"
	default:
		return "Lower urban risk exposure"
	}
}

func main() {
	status := UrbanRiskStatus{
		Name:                    "Floodplain informal settlement",
		FloodExposure:           0.78,
		HeatExposure:            0.66,
		LandslideOrFireExposure: 0.42,
		HousingVulnerability:    0.71,
		InfrastructureDeficit:   0.74,
		ServiceAccess:           0.36,
		TenureSecurity:          0.32,
		LivelihoodPrecarity:     0.68,
		SocialProtectionAccess:  0.30,
		CommunityAdaptation:     0.58,
		InstitutionalProtection: 0.34,
	}

	risk := riskExposure(status)
	protection := protectionCapacity(status)

	fmt.Printf("Settlement: %s\n", status.Name)
	fmt.Printf("Risk exposure score: %.3f\n", risk)
	fmt.Printf("Protection capacity score: %.3f\n", protection)
	fmt.Printf("Protection gap: %.3f\n", protection-risk)
	fmt.Printf("Risk band: %s\n", riskBand(risk))
}

package main

import "fmt"

type MonitoringStatus struct {
	Name                   string
	ObservationCoverage    float64
	DataQuality            float64
	Timeliness             float64
	Interoperability       float64
	AnalyticalCapacity     float64
	WarningDissemination   float64
	CommunityValidation    float64
	ActionLinkage          float64
	RightsSafeguards       float64
	BlindSpots             float64
	UncertaintyBurden      float64
	DecisionLag            float64
	MaintenanceRisk        float64
	MisuseRisk             float64
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

func monitoringCapacity(status MonitoringStatus) float64 {
	return clamp01(
		0.15*status.ObservationCoverage +
			0.14*status.DataQuality +
			0.13*status.Timeliness +
			0.12*status.Interoperability +
			0.12*status.AnalyticalCapacity +
			0.11*status.WarningDissemination +
			0.09*status.CommunityValidation +
			0.09*status.ActionLinkage +
			0.05*status.RightsSafeguards,
	)
}

func monitoringRiskPressure(status MonitoringStatus) float64 {
	return clamp01(
		0.24*status.BlindSpots +
			0.20*status.UncertaintyBurden +
			0.20*status.DecisionLag +
			0.18*status.MaintenanceRisk +
			0.18*status.MisuseRisk,
	)
}

func resilienceBand(score float64) string {
	switch {
	case score >= 0.80:
		return "Strong monitoring-supported resilience"
	case score >= 0.60:
		return "Moderate monitoring-supported resilience"
	case score >= 0.40:
		return "Limited monitoring-supported resilience"
	default:
		return "Weak monitoring-supported resilience"
	}
}

func main() {
	status := MonitoringStatus{
		Name:                 "Integrated flood and climate monitoring system",
		ObservationCoverage:  0.72,
		DataQuality:          0.68,
		Timeliness:           0.70,
		Interoperability:     0.61,
		AnalyticalCapacity:   0.64,
		WarningDissemination: 0.66,
		CommunityValidation:  0.58,
		ActionLinkage:        0.60,
		RightsSafeguards:     0.62,
		BlindSpots:           0.34,
		UncertaintyBurden:    0.38,
		DecisionLag:          0.40,
		MaintenanceRisk:      0.36,
		MisuseRisk:           0.30,
	}

	capacity := monitoringCapacity(status)
	pressure := monitoringRiskPressure(status)
	resilience := clamp01(0.72*capacity + 0.18*status.ActionLinkage + 0.10*status.RightsSafeguards - 0.22*pressure)

	fmt.Printf("Monitoring system: %s\n", status.Name)
	fmt.Printf("Monitoring capacity score: %.3f\n", capacity)
	fmt.Printf("Monitoring risk pressure score: %.3f\n", pressure)
	fmt.Printf("Monitoring-supported resilience score: %.3f\n", resilience)
	fmt.Printf("Monitoring action gap: %.3f\n", capacity-status.ActionLinkage)
	fmt.Printf("Resilience band: %s\n", resilienceBand(resilience))
}

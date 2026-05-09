from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/ai_algorithmic_resilience_panel.csv"
OUTPUT_FILE = "../outputs/ai_algorithmic_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an AI governance and algorithmic resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "jurisdiction",
        "system_domain",
        "model_capability_index",
        "institutional_governance_index",
        "data_quality_index",
        "human_oversight_index",
        "auditability_index",
        "system_robustness_index",
        "equity_testing_index",
        "security_control_index",
        "fallback_capacity_index",
        "public_contestability_index",
        "monitoring_maturity_index",
        "incident_response_index",
        "vendor_accountability_index",
        "opacity_risk_index",
        "bias_severity_index",
        "model_drift_risk_index",
        "automation_dependency_index",
        "vendor_concentration_risk_index",
        "cyber_exposure_index",
        "legitimacy_risk_index",
    ]

    missing = [col for col in required_columns if col not in df.columns]

    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    return df


def validate_indices(df: pd.DataFrame) -> pd.DataFrame:
    """Validate that all *_index fields are complete and normalized to [0, 1]."""
    index_columns = [col for col in df.columns if col.endswith("_index")]

    for col in index_columns:
        if df[col].isna().any():
            raise ValueError(f"Column '{col}' contains missing values.")

        if ((df[col] < 0) | (df[col] > 1)).any():
            raise ValueError(f"Column '{col}' contains values outside [0, 1].")

    return df


def compute_scores(df: pd.DataFrame) -> pd.DataFrame:
    """
    Compute AI resilience capability, governance strength,
    algorithmic fragility pressure, and legitimacy-adjusted readiness.
    """
    df = df.copy()

    df["ai_resilience_capability_score"] = (
        0.18 * df["model_capability_index"] +
        0.16 * df["data_quality_index"] +
        0.15 * df["system_robustness_index"] +
        0.14 * df["monitoring_maturity_index"] +
        0.13 * df["incident_response_index"] +
        0.12 * df["security_control_index"] +
        0.12 * df["fallback_capacity_index"]
    ).clip(lower=0, upper=1)

    df["algorithmic_governance_score"] = (
        0.18 * df["institutional_governance_index"] +
        0.16 * df["human_oversight_index"] +
        0.15 * df["auditability_index"] +
        0.14 * df["equity_testing_index"] +
        0.13 * df["public_contestability_index"] +
        0.12 * df["vendor_accountability_index"] +
        0.12 * df["monitoring_maturity_index"]
    ).clip(lower=0, upper=1)

    df["algorithmic_fragility_pressure_score"] = (
        0.17 * df["opacity_risk_index"] +
        0.16 * df["bias_severity_index"] +
        0.15 * df["model_drift_risk_index"] +
        0.15 * df["automation_dependency_index"] +
        0.14 * df["vendor_concentration_risk_index"] +
        0.13 * df["cyber_exposure_index"] +
        0.10 * df["legitimacy_risk_index"]
    ).clip(lower=0, upper=1)

    df["legitimacy_adjusted_ai_resilience_score"] = (
        0.30 * df["ai_resilience_capability_score"] +
        0.30 * df["algorithmic_governance_score"] +
        0.15 * df["public_contestability_index"] +
        0.10 * df["human_oversight_index"] +
        0.10 * df["equity_testing_index"] +
        0.05 * (1 - df["algorithmic_fragility_pressure_score"])
    ).clip(lower=0, upper=1)

    df["algorithmic_resilience_gap"] = (
        df["legitimacy_adjusted_ai_resilience_score"] -
        df["algorithmic_fragility_pressure_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["legitimacy_adjusted_ai_resilience_score"] >= 0.80,
            df["legitimacy_adjusted_ai_resilience_score"] >= 0.60,
            df["legitimacy_adjusted_ai_resilience_score"] >= 0.40,
        ],
        [
            "Strong algorithmic resilience readiness",
            "Moderate algorithmic resilience readiness",
            "Limited algorithmic resilience readiness",
        ],
        default="Weak algorithmic resilience readiness",
    )

    df["fragility_warning"] = np.select(
        [
            df["algorithmic_fragility_pressure_score"] - df["legitimacy_adjusted_ai_resilience_score"] >= 0.35,
            df["algorithmic_fragility_pressure_score"] - df["legitimacy_adjusted_ai_resilience_score"] >= 0.20,
            df["algorithmic_fragility_pressure_score"] - df["legitimacy_adjusted_ai_resilience_score"] >= 0.05,
        ],
        [
            "Severe algorithmic fragility pressure",
            "High algorithmic fragility pressure",
            "Moderate algorithmic fragility pressure",
        ],
        default="Lower fragility pressure or stronger AI resilience readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for AI resilience governance review."""
    columns = [
        "system_name",
        "jurisdiction",
        "system_domain",
        "ai_resilience_capability_score",
        "algorithmic_governance_score",
        "algorithmic_fragility_pressure_score",
        "legitimacy_adjusted_ai_resilience_score",
        "algorithmic_resilience_gap",
        "resilience_band",
        "fragility_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "legitimacy_adjusted_ai_resilience_score",
                "algorithmic_governance_score",
                "algorithmic_fragility_pressure_score",
            ],
            ascending=[False, False, True],
        )
        .reset_index(drop=True)
    )


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    summary = build_summary(scored)

    summary.to_csv(OUTPUT_FILE, index=False)

    print("AI algorithmic resilience governance scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

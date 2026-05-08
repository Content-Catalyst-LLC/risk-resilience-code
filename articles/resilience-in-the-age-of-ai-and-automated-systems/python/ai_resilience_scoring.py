from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/ai_resilience_system_panel.csv"
OUTPUT_FILE = "../outputs/ai_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an AI-enabled system resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "ai_use_case",
        "model_reliability_index",
        "monitoring_capacity_index",
        "oversight_capacity_index",
        "governance_strength_index",
        "explainability_index",
        "contestability_index",
        "fallback_capacity_index",
        "data_quality_index",
        "bias_management_index",
        "privacy_protection_index",
        "cyber_resilience_index",
        "concentration_risk_index",
        "automation_dependence_index",
        "drift_risk_index",
        "opacity_risk_index",
        "public_accountability_index",
        "service_criticality_index",
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
    Compute AI resilience capacity, automation fragility,
    and resilience-adjusted AI risk.
    """
    df = df.copy()

    df["ai_resilience_capacity_score"] = (
        0.12 * df["model_reliability_index"] +
        0.11 * df["monitoring_capacity_index"] +
        0.11 * df["oversight_capacity_index"] +
        0.11 * df["governance_strength_index"] +
        0.09 * df["explainability_index"] +
        0.09 * df["contestability_index"] +
        0.09 * df["fallback_capacity_index"] +
        0.08 * df["data_quality_index"] +
        0.07 * df["bias_management_index"] +
        0.06 * df["privacy_protection_index"] +
        0.07 * df["cyber_resilience_index"]
    ).clip(lower=0, upper=1)

    df["automation_fragility_score"] = (
        0.16 * df["concentration_risk_index"] +
        0.15 * df["automation_dependence_index"] +
        0.15 * df["drift_risk_index"] +
        0.14 * df["opacity_risk_index"] +
        0.10 * (1 - df["fallback_capacity_index"]) +
        0.10 * (1 - df["monitoring_capacity_index"]) +
        0.08 * (1 - df["oversight_capacity_index"]) +
        0.07 * (1 - df["contestability_index"]) +
        0.05 * (1 - df["public_accountability_index"])
    ).clip(lower=0, upper=1)

    df["resilience_adjusted_ai_risk"] = (
        0.36 * df["automation_fragility_score"] +
        0.22 * (1 - df["ai_resilience_capacity_score"]) +
        0.14 * df["service_criticality_index"] +
        0.10 * df["concentration_risk_index"] +
        0.08 * df["drift_risk_index"] +
        0.05 * df["opacity_risk_index"] +
        0.05 * (1 - df["public_accountability_index"])
    ).clip(lower=0, upper=1)

    df["resilience_gap"] = (
        df["ai_resilience_capacity_score"] -
        df["automation_fragility_score"]
    )

    df["risk_band"] = np.select(
        [
            df["resilience_adjusted_ai_risk"] >= 0.80,
            df["resilience_adjusted_ai_risk"] >= 0.60,
            df["resilience_adjusted_ai_risk"] >= 0.40,
        ],
        [
            "Extreme AI resilience risk",
            "High AI resilience risk",
            "Moderate AI resilience risk",
        ],
        default="Lower AI resilience risk",
    )

    df["governance_warning"] = np.select(
        [
            df["automation_fragility_score"] - df["ai_resilience_capacity_score"] >= 0.35,
            df["automation_fragility_score"] - df["ai_resilience_capacity_score"] >= 0.20,
            df["automation_fragility_score"] - df["ai_resilience_capacity_score"] >= 0.05,
        ],
        [
            "Severe automation-fragility gap",
            "High automation-fragility gap",
            "Moderate automation-fragility gap",
        ],
        default="Lower fragility gap or stronger AI resilience capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for AI resilience review."""
    columns = [
        "system_name",
        "sector",
        "ai_use_case",
        "ai_resilience_capacity_score",
        "automation_fragility_score",
        "resilience_adjusted_ai_risk",
        "resilience_gap",
        "risk_band",
        "governance_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_adjusted_ai_risk",
                "automation_fragility_score",
                "ai_resilience_capacity_score",
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

    print("AI resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

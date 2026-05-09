from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_indicators_panel.csv"
OUTPUT_FILE = "../outputs/resilience_indicator_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a resilience indicator dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "jurisdiction",
        "system_type",
        "capacity_index",
        "asset_index",
        "process_index",
        "outcome_index",
        "equity_protection_index",
        "service_continuity_index",
        "recovery_performance_index",
        "adaptive_learning_index",
        "institutional_capacity_index",
        "ecological_condition_index",
        "social_protection_index",
        "financial_protection_index",
        "vulnerability_index",
        "exposure_index",
        "distributional_inequality_index",
        "measurement_uncertainty_index",
        "data_quality_gap_index",
        "false_precision_risk_index",
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
    Compute measured resilience, indicator confidence,
    measurement vulnerability, and equity-adjusted resilience.
    """
    df = df.copy()

    df["capacity_asset_process_score"] = (
        0.34 * df["capacity_index"] +
        0.33 * df["asset_index"] +
        0.33 * df["process_index"]
    ).clip(lower=0, upper=1)

    df["performance_outcome_score"] = (
        0.22 * df["outcome_index"] +
        0.20 * df["service_continuity_index"] +
        0.18 * df["recovery_performance_index"] +
        0.16 * df["adaptive_learning_index"] +
        0.12 * df["institutional_capacity_index"] +
        0.06 * df["ecological_condition_index"] +
        0.06 * df["social_protection_index"]
    ).clip(lower=0, upper=1)

    df["measurement_vulnerability_score"] = (
        0.22 * df["vulnerability_index"] +
        0.20 * df["exposure_index"] +
        0.18 * df["distributional_inequality_index"] +
        0.15 * df["measurement_uncertainty_index"] +
        0.13 * df["data_quality_gap_index"] +
        0.12 * df["false_precision_risk_index"]
    ).clip(lower=0, upper=1)

    df["measured_resilience_score"] = (
        0.30 * df["capacity_asset_process_score"] +
        0.30 * df["performance_outcome_score"] +
        0.16 * df["equity_protection_index"] +
        0.12 * df["financial_protection_index"] +
        0.12 * (1 - df["measurement_vulnerability_score"])
    ).clip(lower=0, upper=1)

    df["equity_adjusted_resilience_score"] = (
        df["measured_resilience_score"] -
        0.25 * df["distributional_inequality_index"] -
        0.15 * (1 - df["equity_protection_index"])
    ).clip(lower=0, upper=1)

    df["indicator_confidence_score"] = (
        0.50 * (1 - df["measurement_uncertainty_index"]) +
        0.30 * (1 - df["data_quality_gap_index"]) +
        0.20 * (1 - df["false_precision_risk_index"])
    ).clip(lower=0, upper=1)

    df["measurement_gap"] = (
        df["measured_resilience_score"] -
        df["measurement_vulnerability_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["equity_adjusted_resilience_score"] >= 0.80,
            df["equity_adjusted_resilience_score"] >= 0.60,
            df["equity_adjusted_resilience_score"] >= 0.40,
        ],
        [
            "Strong equity-adjusted measured resilience",
            "Moderate equity-adjusted measured resilience",
            "Limited equity-adjusted measured resilience",
        ],
        default="Weak equity-adjusted measured resilience",
    )

    df["measurement_warning"] = np.select(
        [
            df["measurement_vulnerability_score"] - df["measured_resilience_score"] >= 0.35,
            df["measurement_vulnerability_score"] - df["measured_resilience_score"] >= 0.20,
            df["measurement_vulnerability_score"] - df["measured_resilience_score"] >= 0.05,
        ],
        [
            "Severe resilience-measurement vulnerability gap",
            "High resilience-measurement vulnerability gap",
            "Moderate resilience-measurement vulnerability gap",
        ],
        default="Lower measurement vulnerability or stronger measured resilience",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for resilience indicator review."""
    columns = [
        "system_name",
        "jurisdiction",
        "system_type",
        "capacity_asset_process_score",
        "performance_outcome_score",
        "measurement_vulnerability_score",
        "measured_resilience_score",
        "equity_adjusted_resilience_score",
        "indicator_confidence_score",
        "measurement_gap",
        "resilience_band",
        "measurement_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "equity_adjusted_resilience_score",
                "indicator_confidence_score",
                "measurement_vulnerability_score",
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

    print("Resilience indicator scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

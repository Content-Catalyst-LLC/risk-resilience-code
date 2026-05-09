from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/environmental_monitoring_resilience_panel.csv"
OUTPUT_FILE = "../outputs/environmental_monitoring_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an environmental monitoring and resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "monitoring_system_name",
        "jurisdiction",
        "system_domain",
        "observation_coverage_index",
        "data_quality_index",
        "timeliness_index",
        "interoperability_index",
        "analytical_capacity_index",
        "warning_dissemination_index",
        "community_validation_index",
        "action_linkage_index",
        "rights_safeguard_index",
        "blind_spot_index",
        "uncertainty_burden_index",
        "decision_lag_index",
        "maintenance_risk_index",
        "misuse_risk_index",
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
    Compute monitoring capacity, monitoring risk pressure,
    monitoring-supported resilience, and monitoring action gap.
    """
    df = df.copy()

    df["monitoring_capacity_score"] = (
        0.15 * df["observation_coverage_index"]
        + 0.14 * df["data_quality_index"]
        + 0.13 * df["timeliness_index"]
        + 0.12 * df["interoperability_index"]
        + 0.12 * df["analytical_capacity_index"]
        + 0.11 * df["warning_dissemination_index"]
        + 0.09 * df["community_validation_index"]
        + 0.09 * df["action_linkage_index"]
        + 0.05 * df["rights_safeguard_index"]
    ).clip(lower=0, upper=1)

    df["monitoring_risk_pressure_score"] = (
        0.24 * df["blind_spot_index"]
        + 0.20 * df["uncertainty_burden_index"]
        + 0.20 * df["decision_lag_index"]
        + 0.18 * df["maintenance_risk_index"]
        + 0.18 * df["misuse_risk_index"]
    ).clip(lower=0, upper=1)

    df["monitoring_supported_resilience_score"] = (
        0.72 * df["monitoring_capacity_score"]
        + 0.18 * df["action_linkage_index"]
        + 0.10 * df["rights_safeguard_index"]
        - 0.22 * df["monitoring_risk_pressure_score"]
    ).clip(lower=0, upper=1)

    df["monitoring_action_gap"] = (
        df["monitoring_capacity_score"]
        - df["action_linkage_index"]
    )

    df["resilience_band"] = np.select(
        [
            df["monitoring_supported_resilience_score"] >= 0.80,
            df["monitoring_supported_resilience_score"] >= 0.60,
            df["monitoring_supported_resilience_score"] >= 0.40,
        ],
        [
            "Strong monitoring-supported resilience",
            "Moderate monitoring-supported resilience",
            "Limited monitoring-supported resilience",
        ],
        default="Weak monitoring-supported resilience",
    )

    df["monitoring_warning"] = np.select(
        [
            df["monitoring_risk_pressure_score"] - df["monitoring_supported_resilience_score"] >= 0.35,
            df["monitoring_risk_pressure_score"] - df["monitoring_supported_resilience_score"] >= 0.20,
            df["monitoring_risk_pressure_score"] - df["monitoring_supported_resilience_score"] >= 0.05,
        ],
        [
            "Severe monitoring-to-resilience gap",
            "High monitoring-to-resilience gap",
            "Moderate monitoring-to-resilience gap",
        ],
        default="Lower monitoring risk or stronger action linkage",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for monitoring-resilience review."""
    columns = [
        "monitoring_system_name",
        "jurisdiction",
        "system_domain",
        "monitoring_capacity_score",
        "monitoring_risk_pressure_score",
        "monitoring_supported_resilience_score",
        "monitoring_action_gap",
        "resilience_band",
        "monitoring_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "monitoring_supported_resilience_score",
                "monitoring_risk_pressure_score",
                "monitoring_action_gap",
            ],
            ascending=[False, True, True],
        )
        .reset_index(drop=True)
    )


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    summary = build_summary(scored)

    summary.to_csv(OUTPUT_FILE, index=False)

    print("Environmental monitoring resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

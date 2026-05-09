from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/efficiency_slack_resilience_panel.csv"
OUTPUT_FILE = "../outputs/efficiency_slack_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an efficiency, slack, and resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "system_type",
        "routine_efficiency_index",
        "protective_slack_index",
        "redundancy_index",
        "modularity_index",
        "diversity_index",
        "feedback_monitoring_index",
        "repair_capacity_index",
        "governance_quality_index",
        "tight_coupling_index",
        "single_point_dependence_index",
        "overload_index",
        "deferred_maintenance_index",
        "hidden_risk_transfer_index",
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
    Compute resilience-aware performance, optimization fragility pressure,
    and a slack-fragility gap.
    """
    df = df.copy()

    df["resilience_capacity_score"] = (
        0.12 * df["routine_efficiency_index"]
        + 0.16 * df["protective_slack_index"]
        + 0.14 * df["redundancy_index"]
        + 0.13 * df["modularity_index"]
        + 0.12 * df["diversity_index"]
        + 0.12 * df["feedback_monitoring_index"]
        + 0.11 * df["repair_capacity_index"]
        + 0.10 * df["governance_quality_index"]
    ).clip(lower=0, upper=1)

    df["optimization_fragility_pressure_score"] = (
        0.22 * df["tight_coupling_index"]
        + 0.22 * df["single_point_dependence_index"]
        + 0.20 * df["overload_index"]
        + 0.18 * df["deferred_maintenance_index"]
        + 0.18 * df["hidden_risk_transfer_index"]
    ).clip(lower=0, upper=1)

    df["resilience_aware_performance_score"] = (
        0.70 * df["resilience_capacity_score"]
        - 0.30 * df["optimization_fragility_pressure_score"]
    ).clip(lower=0, upper=1)

    df["slack_fragility_gap"] = (
        df["resilience_capacity_score"]
        - df["optimization_fragility_pressure_score"]
    )

    df["system_design_band"] = np.select(
        [
            df["resilience_aware_performance_score"] >= 0.80,
            df["resilience_aware_performance_score"] >= 0.60,
            df["resilience_aware_performance_score"] >= 0.40,
        ],
        [
            "Resilient efficiency",
            "Moderate resilience-aware performance",
            "Limited resilience-aware performance",
        ],
        default="Fragility-producing optimization",
    )

    df["design_warning"] = np.select(
        [
            df["optimization_fragility_pressure_score"] - df["resilience_capacity_score"] >= 0.35,
            df["optimization_fragility_pressure_score"] - df["resilience_capacity_score"] >= 0.20,
            df["optimization_fragility_pressure_score"] - df["resilience_capacity_score"] >= 0.05,
        ],
        [
            "Severe optimization-fragility deficit",
            "High optimization-fragility deficit",
            "Moderate optimization-fragility deficit",
        ],
        default="Lower fragility pressure or stronger resilience capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for efficiency-slack-resilience review."""
    columns = [
        "system_name",
        "sector",
        "system_type",
        "resilience_capacity_score",
        "optimization_fragility_pressure_score",
        "resilience_aware_performance_score",
        "slack_fragility_gap",
        "system_design_band",
        "design_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_aware_performance_score",
                "optimization_fragility_pressure_score",
                "slack_fragility_gap",
            ],
            ascending=[False, True, False],
        )
        .reset_index(drop=True)
    )


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    summary = build_summary(scored)

    summary.to_csv(OUTPUT_FILE, index=False)

    print("Efficiency, slack, and resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

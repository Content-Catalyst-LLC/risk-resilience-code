from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/tight_coupling_catastrophic_failure_panel.csv"
OUTPUT_FILE = "../outputs/tight_coupling_catastrophic_failure_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a tight-coupling catastrophic-failure dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "system_type",
        "coupling_strength_index",
        "time_compression_index",
        "sequence_rigidity_index",
        "limited_substitution_index",
        "interactive_complexity_index",
        "hidden_dependency_index",
        "critical_node_importance_index",
        "buffering_index",
        "modularity_index",
        "redundancy_index",
        "adaptive_authority_index",
        "fallback_capacity_index",
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
    Compute tight-coupling pressure, resilience room,
    catastrophic-failure risk, and containment margin.
    """
    df = df.copy()

    df["tight_coupling_pressure_score"] = (
        0.16 * df["coupling_strength_index"]
        + 0.16 * df["time_compression_index"]
        + 0.14 * df["sequence_rigidity_index"]
        + 0.13 * df["limited_substitution_index"]
        + 0.15 * df["interactive_complexity_index"]
        + 0.12 * df["hidden_dependency_index"]
        + 0.14 * df["critical_node_importance_index"]
    ).clip(lower=0, upper=1)

    df["resilience_room_score"] = (
        0.22 * df["buffering_index"]
        + 0.20 * df["modularity_index"]
        + 0.20 * df["redundancy_index"]
        + 0.20 * df["adaptive_authority_index"]
        + 0.18 * df["fallback_capacity_index"]
    ).clip(lower=0, upper=1)

    df["catastrophic_failure_risk_score"] = (
        0.74 * df["tight_coupling_pressure_score"]
        - 0.26 * df["resilience_room_score"]
    ).clip(lower=0, upper=1)

    df["containment_margin"] = (
        df["resilience_room_score"]
        - df["tight_coupling_pressure_score"]
    )

    df["failure_risk_band"] = np.select(
        [
            df["catastrophic_failure_risk_score"] >= 0.80,
            df["catastrophic_failure_risk_score"] >= 0.60,
            df["catastrophic_failure_risk_score"] >= 0.40,
        ],
        [
            "Severe tight-coupling catastrophic-failure risk",
            "High tight-coupling catastrophic-failure risk",
            "Moderate tight-coupling catastrophic-failure risk",
        ],
        default="Lower tight-coupling catastrophic-failure risk",
    )

    df["containment_warning"] = np.select(
        [
            df["tight_coupling_pressure_score"] - df["resilience_room_score"] >= 0.35,
            df["tight_coupling_pressure_score"] - df["resilience_room_score"] >= 0.20,
            df["tight_coupling_pressure_score"] - df["resilience_room_score"] >= 0.05,
        ],
        [
            "Severe containment deficit",
            "High containment deficit",
            "Moderate containment deficit",
        ],
        default="Lower deficit or stronger resilience room",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for tight-coupling review."""
    columns = [
        "system_name",
        "sector",
        "system_type",
        "tight_coupling_pressure_score",
        "resilience_room_score",
        "catastrophic_failure_risk_score",
        "containment_margin",
        "failure_risk_band",
        "containment_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "catastrophic_failure_risk_score",
                "tight_coupling_pressure_score",
                "containment_margin",
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

    print("Tight-coupling catastrophic-failure scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

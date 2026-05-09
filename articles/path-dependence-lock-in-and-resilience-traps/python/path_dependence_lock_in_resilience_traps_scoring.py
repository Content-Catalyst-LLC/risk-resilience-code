from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/path_dependence_lock_in_resilience_traps_panel.csv"
OUTPUT_FILE = "../outputs/path_dependence_lock_in_resilience_traps_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a path dependence, lock-in, and resilience trap dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "pathway_type",
        "sunk_cost_index",
        "infrastructure_rigidity_index",
        "institutional_inertia_index",
        "incumbent_power_index",
        "social_dependence_index",
        "technological_incompatibility_index",
        "ecological_feedback_index",
        "alternative_capacity_index",
        "adaptive_governance_index",
        "public_legitimacy_index",
        "justice_transition_index",
        "reversibility_index",
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
    Compute lock-in pressure, transformation capacity,
    resilience trap risk, and transformation readiness.
    """
    df = df.copy()

    df["lock_in_pressure_score"] = (
        0.16 * df["sunk_cost_index"]
        + 0.16 * df["infrastructure_rigidity_index"]
        + 0.16 * df["institutional_inertia_index"]
        + 0.16 * df["incumbent_power_index"]
        + 0.14 * df["social_dependence_index"]
        + 0.11 * df["technological_incompatibility_index"]
        + 0.11 * df["ecological_feedback_index"]
    ).clip(lower=0, upper=1)

    df["transformation_capacity_score"] = (
        0.22 * df["alternative_capacity_index"]
        + 0.22 * df["adaptive_governance_index"]
        + 0.18 * df["public_legitimacy_index"]
        + 0.20 * df["justice_transition_index"]
        + 0.18 * df["reversibility_index"]
    ).clip(lower=0, upper=1)

    df["resilience_trap_risk_score"] = (
        0.72 * df["lock_in_pressure_score"]
        - 0.28 * df["transformation_capacity_score"]
    ).clip(lower=0, upper=1)

    df["transformation_readiness_score"] = (
        0.68 * df["transformation_capacity_score"]
        - 0.32 * df["lock_in_pressure_score"]
    ).clip(lower=0, upper=1)

    df["escape_gap"] = (
        df["transformation_capacity_score"]
        - df["lock_in_pressure_score"]
    )

    df["trap_band"] = np.select(
        [
            df["resilience_trap_risk_score"] >= 0.80,
            df["resilience_trap_risk_score"] >= 0.60,
            df["resilience_trap_risk_score"] >= 0.40,
        ],
        [
            "Severe resilience trap risk",
            "High resilience trap risk",
            "Moderate resilience trap risk",
        ],
        default="Lower resilience trap risk",
    )

    df["transformation_warning"] = np.select(
        [
            df["lock_in_pressure_score"] - df["transformation_capacity_score"] >= 0.35,
            df["lock_in_pressure_score"] - df["transformation_capacity_score"] >= 0.20,
            df["lock_in_pressure_score"] - df["transformation_capacity_score"] >= 0.05,
        ],
        [
            "Severe transformation deficit",
            "High transformation deficit",
            "Moderate transformation deficit",
        ],
        default="Lower deficit or stronger transformation capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for lock-in and resilience trap review."""
    columns = [
        "system_name",
        "sector",
        "pathway_type",
        "lock_in_pressure_score",
        "transformation_capacity_score",
        "resilience_trap_risk_score",
        "transformation_readiness_score",
        "escape_gap",
        "trap_band",
        "transformation_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_trap_risk_score",
                "lock_in_pressure_score",
                "escape_gap",
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

    print("Path dependence, lock-in, and resilience trap scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

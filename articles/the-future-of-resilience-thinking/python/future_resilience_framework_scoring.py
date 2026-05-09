from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/future_resilience_framework_panel.csv"
OUTPUT_FILE = "../outputs/future_resilience_framework_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a future-oriented resilience framework dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "strategy_name",
        "jurisdiction",
        "strategy_domain",
        "systemic_risk_capacity_index",
        "governance_integration_index",
        "justice_transformation_index",
        "regenerative_capacity_index",
        "local_capability_index",
        "technological_accountability_index",
        "planetary_alignment_index",
        "investment_readiness_index",
        "data_accountability_index",
        "learning_capacity_index",
        "fragmentation_risk_index",
        "maladaptation_risk_index",
        "inequality_risk_index",
        "ecological_overshoot_risk_index",
        "technological_dependency_risk_index",
        "conceptual_vagueness_index",
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
    Compute future-oriented resilience capacity, fragility pressure,
    conceptual discipline, and readiness gap.
    """
    df = df.copy()

    df["future_resilience_capacity_score"] = (
        0.14 * df["systemic_risk_capacity_index"] +
        0.13 * df["governance_integration_index"] +
        0.12 * df["justice_transformation_index"] +
        0.12 * df["regenerative_capacity_index"] +
        0.10 * df["local_capability_index"] +
        0.10 * df["technological_accountability_index"] +
        0.10 * df["planetary_alignment_index"] +
        0.08 * df["investment_readiness_index"] +
        0.06 * df["data_accountability_index"] +
        0.05 * df["learning_capacity_index"]
    ).clip(lower=0, upper=1)

    df["future_fragility_pressure_score"] = (
        0.18 * df["fragmentation_risk_index"] +
        0.18 * df["maladaptation_risk_index"] +
        0.17 * df["inequality_risk_index"] +
        0.17 * df["ecological_overshoot_risk_index"] +
        0.15 * df["technological_dependency_risk_index"] +
        0.15 * df["conceptual_vagueness_index"]
    ).clip(lower=0, upper=1)

    df["conceptual_discipline_score"] = (
        0.30 * (1 - df["conceptual_vagueness_index"]) +
        0.25 * df["data_accountability_index"] +
        0.25 * df["learning_capacity_index"] +
        0.20 * df["governance_integration_index"]
    ).clip(lower=0, upper=1)

    df["future_resilience_readiness_gap"] = (
        df["future_resilience_capacity_score"] -
        df["future_fragility_pressure_score"]
    )

    df["resilience_future_band"] = np.select(
        [
            df["future_resilience_capacity_score"] >= 0.80,
            df["future_resilience_capacity_score"] >= 0.60,
            df["future_resilience_capacity_score"] >= 0.40,
        ],
        [
            "Strong future-oriented resilience framework",
            "Moderate future-oriented resilience framework",
            "Limited future-oriented resilience framework",
        ],
        default="Weak future-oriented resilience framework",
    )

    df["future_warning"] = np.select(
        [
            df["future_fragility_pressure_score"] - df["future_resilience_capacity_score"] >= 0.35,
            df["future_fragility_pressure_score"] - df["future_resilience_capacity_score"] >= 0.20,
            df["future_fragility_pressure_score"] - df["future_resilience_capacity_score"] >= 0.05,
        ],
        [
            "Severe future resilience readiness gap",
            "High future resilience readiness gap",
            "Moderate future resilience readiness gap",
        ],
        default="Lower fragility pressure or stronger future resilience readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for future resilience review."""
    columns = [
        "strategy_name",
        "jurisdiction",
        "strategy_domain",
        "future_resilience_capacity_score",
        "future_fragility_pressure_score",
        "conceptual_discipline_score",
        "future_resilience_readiness_gap",
        "resilience_future_band",
        "future_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "future_resilience_readiness_gap",
                "future_resilience_capacity_score",
                "future_fragility_pressure_score",
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

    print("Future resilience framework scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

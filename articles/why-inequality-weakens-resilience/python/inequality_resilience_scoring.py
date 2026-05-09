from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/inequality_resilience_panel.csv"
OUTPUT_FILE = "../outputs/inequality_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an inequality and resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "place_name",
        "jurisdiction",
        "place_type",
        "system_capacity_index",
        "distributed_protection_index",
        "household_buffer_index",
        "service_access_index",
        "institutional_trust_index",
        "adaptive_capacity_index",
        "social_protection_index",
        "community_voice_index",
        "exposure_concentration_index",
        "multidimensional_deprivation_index",
        "social_exclusion_index",
        "recovery_inequality_index",
        "digital_exclusion_index",
        "fiscal_stress_index",
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
    Compute aggregate resilience, equality-adjusted resilience,
    inequality pressure, and resilience inequality gap.
    """
    df = df.copy()

    df["aggregate_resilience_capacity_score"] = (
        0.22 * df["system_capacity_index"]
        + 0.18 * df["service_access_index"]
        + 0.16 * df["adaptive_capacity_index"]
        + 0.14 * df["social_protection_index"]
        + 0.12 * df["institutional_trust_index"]
        + 0.10 * df["household_buffer_index"]
        + 0.08 * df["community_voice_index"]
    ).clip(lower=0, upper=1)

    df["inequality_pressure_score"] = (
        0.22 * df["exposure_concentration_index"]
        + 0.20 * df["multidimensional_deprivation_index"]
        + 0.18 * df["social_exclusion_index"]
        + 0.16 * df["recovery_inequality_index"]
        + 0.13 * df["digital_exclusion_index"]
        + 0.11 * df["fiscal_stress_index"]
    ).clip(lower=0, upper=1)

    df["equality_adjusted_resilience_score"] = (
        0.18 * df["system_capacity_index"]
        + 0.18 * df["distributed_protection_index"]
        + 0.15 * df["household_buffer_index"]
        + 0.15 * df["service_access_index"]
        + 0.12 * df["institutional_trust_index"]
        + 0.12 * df["adaptive_capacity_index"]
        + 0.06 * df["social_protection_index"]
        + 0.04 * df["community_voice_index"]
        - 0.18 * df["inequality_pressure_score"]
    ).clip(lower=0, upper=1)

    df["resilience_inequality_gap"] = (
        df["aggregate_resilience_capacity_score"]
        - df["equality_adjusted_resilience_score"]
    )

    df["protection_gap"] = (
        df["distributed_protection_index"]
        - df["exposure_concentration_index"]
    )

    df["resilience_band"] = np.select(
        [
            df["equality_adjusted_resilience_score"] >= 0.80,
            df["equality_adjusted_resilience_score"] >= 0.60,
            df["equality_adjusted_resilience_score"] >= 0.40,
        ],
        [
            "Strong equality-adjusted resilience",
            "Moderate equality-adjusted resilience",
            "Limited equality-adjusted resilience",
        ],
        default="Weak equality-adjusted resilience",
    )

    df["inequality_warning"] = np.select(
        [
            df["inequality_pressure_score"] - df["equality_adjusted_resilience_score"] >= 0.35,
            df["inequality_pressure_score"] - df["equality_adjusted_resilience_score"] >= 0.20,
            df["inequality_pressure_score"] - df["equality_adjusted_resilience_score"] >= 0.05,
        ],
        [
            "Severe inequality-driven fragility",
            "High inequality-driven fragility",
            "Moderate inequality-driven fragility",
        ],
        default="Lower inequality pressure or stronger distributed resilience",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for inequality and resilience review."""
    columns = [
        "place_name",
        "jurisdiction",
        "place_type",
        "aggregate_resilience_capacity_score",
        "equality_adjusted_resilience_score",
        "inequality_pressure_score",
        "resilience_inequality_gap",
        "protection_gap",
        "resilience_band",
        "inequality_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "equality_adjusted_resilience_score",
                "inequality_pressure_score",
                "resilience_inequality_gap",
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

    print("Inequality and resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

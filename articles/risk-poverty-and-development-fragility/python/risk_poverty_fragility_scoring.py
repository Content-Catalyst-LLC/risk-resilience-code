from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/risk_poverty_development_fragility_panel.csv"
OUTPUT_FILE = "../outputs/risk_poverty_development_fragility_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a poverty, risk, and development fragility dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "place_name",
        "jurisdiction",
        "place_type",
        "risk_exposure_index",
        "multidimensional_poverty_index",
        "institutional_weakness_index",
        "livelihood_precarity_index",
        "service_deficit_index",
        "conflict_pressure_index",
        "climate_stress_index",
        "displacement_pressure_index",
        "social_protection_index",
        "household_buffer_index",
        "adaptive_capacity_index",
        "service_continuity_index",
        "institutional_trust_index",
        "community_voice_index",
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
    Compute development fragility, resilience sufficiency,
    and the poverty-fragility gap.
    """
    df = df.copy()

    df["development_fragility_score"] = (
        0.18 * df["risk_exposure_index"]
        + 0.17 * df["multidimensional_poverty_index"]
        + 0.15 * df["institutional_weakness_index"]
        + 0.14 * df["livelihood_precarity_index"]
        + 0.13 * df["service_deficit_index"]
        + 0.10 * df["conflict_pressure_index"]
        + 0.08 * df["climate_stress_index"]
        + 0.05 * df["displacement_pressure_index"]
    ).clip(lower=0, upper=1)

    df["resilience_sufficiency_score"] = (
        0.18 * df["social_protection_index"]
        + 0.17 * df["household_buffer_index"]
        + 0.17 * df["adaptive_capacity_index"]
        + 0.16 * df["service_continuity_index"]
        + 0.16 * df["institutional_trust_index"]
        + 0.16 * df["community_voice_index"]
    ).clip(lower=0, upper=1)

    df["poverty_fragility_gap"] = (
        df["resilience_sufficiency_score"]
        - df["development_fragility_score"]
    )

    df["fragility_band"] = np.select(
        [
            df["development_fragility_score"] >= 0.80,
            df["development_fragility_score"] >= 0.60,
            df["development_fragility_score"] >= 0.40,
        ],
        [
            "Extreme development fragility",
            "High development fragility",
            "Moderate development fragility",
        ],
        default="Lower development fragility",
    )

    df["resilience_warning"] = np.select(
        [
            df["development_fragility_score"] - df["resilience_sufficiency_score"] >= 0.35,
            df["development_fragility_score"] - df["resilience_sufficiency_score"] >= 0.20,
            df["development_fragility_score"] - df["resilience_sufficiency_score"] >= 0.05,
        ],
        [
            "Severe poverty-fragility resilience gap",
            "High poverty-fragility resilience gap",
            "Moderate poverty-fragility resilience gap",
        ],
        default="Lower gap or stronger resilience sufficiency",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for poverty-fragility review."""
    columns = [
        "place_name",
        "jurisdiction",
        "place_type",
        "development_fragility_score",
        "resilience_sufficiency_score",
        "poverty_fragility_gap",
        "fragility_band",
        "resilience_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "poverty_fragility_gap",
                "resilience_sufficiency_score",
                "development_fragility_score",
            ],
            ascending=[True, True, False],
        )
        .reset_index(drop=True)
    )


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    summary = build_summary(scored)

    summary.to_csv(OUTPUT_FILE, index=False)

    print("Risk, poverty, and development fragility scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

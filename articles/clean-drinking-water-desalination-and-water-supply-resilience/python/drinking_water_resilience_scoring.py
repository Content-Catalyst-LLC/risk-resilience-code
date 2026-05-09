from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/drinking_water_resilience_panel.csv"
OUTPUT_FILE = "../outputs/drinking_water_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a drinking-water resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "water_system_name",
        "jurisdiction",
        "system_type",
        "source_protection_index",
        "treatment_capacity_index",
        "distribution_reliability_index",
        "monitoring_quality_index",
        "supply_diversity_index",
        "energy_resilience_index",
        "affordability_index",
        "governance_capacity_index",
        "contamination_risk_index",
        "infrastructure_aging_index",
        "salinity_pressure_index",
        "energy_dependence_index",
        "brine_burden_index",
        "access_inequality_index",
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
    Compute drinking-water resilience, water-system risk pressure,
    and a source-to-tap resilience gap.
    """
    df = df.copy()

    df["water_resilience_capacity_score"] = (
        0.15 * df["source_protection_index"]
        + 0.16 * df["treatment_capacity_index"]
        + 0.15 * df["distribution_reliability_index"]
        + 0.14 * df["monitoring_quality_index"]
        + 0.11 * df["supply_diversity_index"]
        + 0.10 * df["energy_resilience_index"]
        + 0.09 * df["affordability_index"]
        + 0.10 * df["governance_capacity_index"]
    ).clip(lower=0, upper=1)

    df["water_system_risk_pressure_score"] = (
        0.22 * df["contamination_risk_index"]
        + 0.18 * df["infrastructure_aging_index"]
        + 0.16 * df["salinity_pressure_index"]
        + 0.15 * df["energy_dependence_index"]
        + 0.13 * df["brine_burden_index"]
        + 0.16 * df["access_inequality_index"]
    ).clip(lower=0, upper=1)

    df["drinking_water_resilience_score"] = (
        0.72 * df["water_resilience_capacity_score"]
        - 0.28 * df["water_system_risk_pressure_score"]
    ).clip(lower=0, upper=1)

    df["source_to_tap_resilience_gap"] = (
        df["water_resilience_capacity_score"]
        - df["water_system_risk_pressure_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["drinking_water_resilience_score"] >= 0.80,
            df["drinking_water_resilience_score"] >= 0.60,
            df["drinking_water_resilience_score"] >= 0.40,
        ],
        [
            "Strong drinking-water resilience",
            "Moderate drinking-water resilience",
            "Limited drinking-water resilience",
        ],
        default="Weak drinking-water resilience",
    )

    df["water_safety_warning"] = np.select(
        [
            df["water_system_risk_pressure_score"] - df["water_resilience_capacity_score"] >= 0.35,
            df["water_system_risk_pressure_score"] - df["water_resilience_capacity_score"] >= 0.20,
            df["water_system_risk_pressure_score"] - df["water_resilience_capacity_score"] >= 0.05,
        ],
        [
            "Severe source-to-tap resilience deficit",
            "High source-to-tap resilience deficit",
            "Moderate source-to-tap resilience deficit",
        ],
        default="Lower deficit or stronger water-system capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for drinking-water resilience review."""
    columns = [
        "water_system_name",
        "jurisdiction",
        "system_type",
        "water_resilience_capacity_score",
        "water_system_risk_pressure_score",
        "drinking_water_resilience_score",
        "source_to_tap_resilience_gap",
        "resilience_band",
        "water_safety_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "drinking_water_resilience_score",
                "water_system_risk_pressure_score",
                "source_to_tap_resilience_gap",
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

    print("Drinking-water resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

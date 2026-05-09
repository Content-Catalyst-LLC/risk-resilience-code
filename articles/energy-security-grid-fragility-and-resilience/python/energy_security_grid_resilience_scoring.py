from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/energy_security_grid_resilience_panel.csv"
OUTPUT_FILE = "../outputs/energy_security_grid_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an energy security and grid resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "energy_system_name",
        "jurisdiction",
        "system_type",
        "reliability_index",
        "adequacy_index",
        "redundancy_index",
        "flexibility_index",
        "distributed_capacity_index",
        "cyber_resilience_index",
        "restoration_capacity_index",
        "critical_load_protection_index",
        "affordability_index",
        "equity_protection_index",
        "climate_exposure_index",
        "infrastructure_aging_index",
        "fuel_dependence_index",
        "digital_fragility_index",
        "load_growth_pressure_index",
        "interdependency_risk_index",
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
    Compute energy resilience, grid fragility pressure,
    just energy resilience, and an overall energy-security resilience score.
    """
    df = df.copy()

    df["energy_resilience_capacity_score"] = (
        0.14 * df["reliability_index"]
        + 0.13 * df["adequacy_index"]
        + 0.13 * df["redundancy_index"]
        + 0.12 * df["flexibility_index"]
        + 0.11 * df["distributed_capacity_index"]
        + 0.11 * df["cyber_resilience_index"]
        + 0.13 * df["restoration_capacity_index"]
        + 0.13 * df["critical_load_protection_index"]
    ).clip(lower=0, upper=1)

    df["grid_fragility_pressure_score"] = (
        0.18 * df["climate_exposure_index"]
        + 0.17 * df["infrastructure_aging_index"]
        + 0.15 * df["fuel_dependence_index"]
        + 0.15 * df["digital_fragility_index"]
        + 0.18 * df["load_growth_pressure_index"]
        + 0.17 * df["interdependency_risk_index"]
    ).clip(lower=0, upper=1)

    df["just_energy_resilience_score"] = (
        0.24 * df["affordability_index"]
        + 0.24 * df["equity_protection_index"]
        + 0.22 * df["critical_load_protection_index"]
        + 0.16 * df["distributed_capacity_index"]
        + 0.14 * df["restoration_capacity_index"]
    ).clip(lower=0, upper=1)

    df["energy_security_resilience_score"] = (
        0.58 * df["energy_resilience_capacity_score"]
        + 0.22 * df["just_energy_resilience_score"]
        - 0.28 * df["grid_fragility_pressure_score"]
    ).clip(lower=0, upper=1)

    df["resilience_fragility_gap"] = (
        df["energy_resilience_capacity_score"]
        - df["grid_fragility_pressure_score"]
    )

    df["risk_band"] = np.select(
        [
            df["energy_security_resilience_score"] >= 0.80,
            df["energy_security_resilience_score"] >= 0.60,
            df["energy_security_resilience_score"] >= 0.40,
        ],
        [
            "Strong energy security resilience",
            "Moderate energy security resilience",
            "Limited energy security resilience",
        ],
        default="Weak energy security resilience",
    )

    df["fragility_warning"] = np.select(
        [
            df["grid_fragility_pressure_score"] - df["energy_resilience_capacity_score"] >= 0.35,
            df["grid_fragility_pressure_score"] - df["energy_resilience_capacity_score"] >= 0.20,
            df["grid_fragility_pressure_score"] - df["energy_resilience_capacity_score"] >= 0.05,
        ],
        [
            "Severe grid fragility deficit",
            "High grid fragility deficit",
            "Moderate grid fragility deficit",
        ],
        default="Lower fragility pressure or stronger resilience capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for energy resilience review."""
    columns = [
        "energy_system_name",
        "jurisdiction",
        "system_type",
        "energy_resilience_capacity_score",
        "grid_fragility_pressure_score",
        "just_energy_resilience_score",
        "energy_security_resilience_score",
        "resilience_fragility_gap",
        "risk_band",
        "fragility_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "energy_security_resilience_score",
                "grid_fragility_pressure_score",
                "resilience_fragility_gap",
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

    print("Energy security and grid resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

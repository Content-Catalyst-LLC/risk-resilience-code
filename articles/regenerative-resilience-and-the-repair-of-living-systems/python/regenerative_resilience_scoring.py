from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/regenerative_resilience_panel.csv"
OUTPUT_FILE = "../outputs/regenerative_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a regenerative resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "jurisdiction",
        "system_type",
        "ecosystem_integrity_index",
        "biodiversity_index",
        "soil_health_index",
        "water_function_index",
        "connectivity_index",
        "local_stewardship_index",
        "governance_accountability_index",
        "justice_repair_index",
        "monitoring_quality_index",
        "degradation_pressure_index",
        "fragmentation_pressure_index",
        "extraction_pressure_index",
        "pollution_pressure_index",
        "climate_stress_index",
        "maladaptation_risk_index",
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
    Compute regenerative capacity, degradation pressure,
    and the living-systems repair gap.
    """
    df = df.copy()

    df["regenerative_capacity_score"] = (
        0.15 * df["ecosystem_integrity_index"] +
        0.14 * df["biodiversity_index"] +
        0.14 * df["soil_health_index"] +
        0.13 * df["water_function_index"] +
        0.12 * df["connectivity_index"] +
        0.10 * df["local_stewardship_index"] +
        0.10 * df["governance_accountability_index"] +
        0.08 * df["justice_repair_index"] +
        0.04 * df["monitoring_quality_index"]
    ).clip(lower=0, upper=1)

    df["degradation_pressure_score"] = (
        0.20 * df["degradation_pressure_index"] +
        0.17 * df["fragmentation_pressure_index"] +
        0.16 * df["extraction_pressure_index"] +
        0.15 * df["pollution_pressure_index"] +
        0.18 * df["climate_stress_index"] +
        0.14 * df["maladaptation_risk_index"]
    ).clip(lower=0, upper=1)

    df["living_systems_repair_gap"] = (
        df["regenerative_capacity_score"] -
        df["degradation_pressure_score"]
    )

    df["regenerative_resilience_band"] = np.select(
        [
            df["regenerative_capacity_score"] >= 0.80,
            df["regenerative_capacity_score"] >= 0.60,
            df["regenerative_capacity_score"] >= 0.40,
        ],
        [
            "Strong regenerative resilience",
            "Moderate regenerative resilience",
            "Limited regenerative resilience",
        ],
        default="Weak regenerative resilience",
    )

    df["repair_warning"] = np.select(
        [
            df["degradation_pressure_score"] - df["regenerative_capacity_score"] >= 0.35,
            df["degradation_pressure_score"] - df["regenerative_capacity_score"] >= 0.20,
            df["degradation_pressure_score"] - df["regenerative_capacity_score"] >= 0.05,
        ],
        [
            "Severe living-systems repair gap",
            "High living-systems repair gap",
            "Moderate living-systems repair gap",
        ],
        default="Lower repair gap or stronger regenerative capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for regenerative resilience review."""
    columns = [
        "system_name",
        "jurisdiction",
        "system_type",
        "regenerative_capacity_score",
        "degradation_pressure_score",
        "living_systems_repair_gap",
        "regenerative_resilience_band",
        "repair_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "living_systems_repair_gap",
                "regenerative_capacity_score",
                "degradation_pressure_score",
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

    print("Regenerative resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/urban_informality_risk_exposure_panel.csv"
OUTPUT_FILE = "../outputs/urban_informality_risk_exposure_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """Load an urban informality and risk exposure dataset."""
    df = pd.read_csv(path)

    required_columns = [
        "settlement_name",
        "city",
        "country_or_region",
        "settlement_type",
        "flood_exposure_index",
        "heat_exposure_index",
        "landslide_or_fire_exposure_index",
        "housing_vulnerability_index",
        "infrastructure_deficit_index",
        "service_access_index",
        "tenure_security_index",
        "livelihood_precarity_index",
        "social_protection_access_index",
        "community_adaptation_index",
        "institutional_protection_index",
        "climate_stress_index",
        "displacement_pressure_index",
        "data_visibility_index",
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
    """Compute hazard exposure, vulnerability, protection capacity, and protection gap."""
    df = df.copy()

    df["hazard_exposure_score"] = (
        0.38 * df["flood_exposure_index"]
        + 0.34 * df["heat_exposure_index"]
        + 0.28 * df["landslide_or_fire_exposure_index"]
    ).clip(lower=0, upper=1)

    df["urban_vulnerability_score"] = (
        0.24 * df["housing_vulnerability_index"]
        + 0.22 * df["infrastructure_deficit_index"]
        + 0.18 * df["livelihood_precarity_index"]
        + 0.14 * (1 - df["tenure_security_index"])
        + 0.12 * df["displacement_pressure_index"]
        + 0.10 * (1 - df["social_protection_access_index"])
    ).clip(lower=0, upper=1)

    df["risk_exposure_score"] = (
        0.34 * df["hazard_exposure_score"]
        + 0.30 * df["urban_vulnerability_score"]
        + 0.16 * df["climate_stress_index"]
        + 0.12 * df["infrastructure_deficit_index"]
        + 0.08 * df["displacement_pressure_index"]
    ).clip(lower=0, upper=1)

    df["inclusive_protection_capacity_score"] = (
        0.18 * df["service_access_index"]
        + 0.16 * df["tenure_security_index"]
        + 0.16 * df["community_adaptation_index"]
        + 0.15 * df["institutional_protection_index"]
        + 0.13 * df["social_protection_access_index"]
        + 0.12 * df["data_visibility_index"]
        + 0.10 * (1 - df["infrastructure_deficit_index"])
    ).clip(lower=0, upper=1)

    df["urban_protection_gap"] = (
        df["inclusive_protection_capacity_score"]
        - df["risk_exposure_score"]
    )

    df["risk_band"] = np.select(
        [
            df["risk_exposure_score"] >= 0.80,
            df["risk_exposure_score"] >= 0.60,
            df["risk_exposure_score"] >= 0.40,
        ],
        [
            "Severe urban risk exposure",
            "High urban risk exposure",
            "Moderate urban risk exposure",
        ],
        default="Lower urban risk exposure",
    )

    df["protection_warning"] = np.select(
        [
            df["risk_exposure_score"] - df["inclusive_protection_capacity_score"] >= 0.35,
            df["risk_exposure_score"] - df["inclusive_protection_capacity_score"] >= 0.20,
            df["risk_exposure_score"] - df["inclusive_protection_capacity_score"] >= 0.05,
        ],
        [
            "Severe urban protection gap",
            "High urban protection gap",
            "Moderate urban protection gap",
        ],
        default="Lower protection gap or stronger inclusive protection",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for urban resilience review."""
    columns = [
        "settlement_name",
        "city",
        "country_or_region",
        "settlement_type",
        "hazard_exposure_score",
        "urban_vulnerability_score",
        "risk_exposure_score",
        "inclusive_protection_capacity_score",
        "urban_protection_gap",
        "risk_band",
        "protection_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "urban_protection_gap",
                "inclusive_protection_capacity_score",
                "risk_exposure_score",
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

    print("Urban informality and risk exposure scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

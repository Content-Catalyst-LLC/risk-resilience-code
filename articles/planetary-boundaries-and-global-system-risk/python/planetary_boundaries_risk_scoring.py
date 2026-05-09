from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/planetary_boundaries_risk_panel.csv"
OUTPUT_FILE = "../outputs/planetary_boundaries_risk_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a planetary boundaries risk dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "boundary_name",
        "earth_system_domain",
        "boundary_status",
        "boundary_transgression_index",
        "pressure_trend_index",
        "interaction_strength_index",
        "reversibility_risk_index",
        "human_system_exposure_index",
        "monitoring_confidence_index",
        "adaptive_capacity_index",
        "governance_quality_index",
        "justice_transition_index",
        "policy_response_index",
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
    Compute planetary system risk, response capacity,
    and an Earth-system resilience margin proxy.
    """
    df = df.copy()

    df["planetary_pressure_score"] = (
        0.26 * df["boundary_transgression_index"]
        + 0.22 * df["pressure_trend_index"]
        + 0.20 * df["interaction_strength_index"]
        + 0.18 * df["reversibility_risk_index"]
        + 0.14 * df["human_system_exposure_index"]
    ).clip(lower=0, upper=1)

    df["response_capacity_score"] = (
        0.22 * df["adaptive_capacity_index"]
        + 0.22 * df["governance_quality_index"]
        + 0.18 * df["justice_transition_index"]
        + 0.18 * df["policy_response_index"]
        + 0.20 * df["monitoring_confidence_index"]
    ).clip(lower=0, upper=1)

    df["planetary_system_risk_score"] = (
        0.74 * df["planetary_pressure_score"]
        + 0.18 * df["human_system_exposure_index"]
        + 0.08 * df["reversibility_risk_index"]
        - 0.24 * df["response_capacity_score"]
    ).clip(lower=0, upper=1)

    df["earth_system_resilience_margin"] = (
        df["response_capacity_score"] - df["planetary_pressure_score"]
    )

    df["risk_band"] = np.select(
        [
            df["planetary_system_risk_score"] >= 0.80,
            df["planetary_system_risk_score"] >= 0.60,
            df["planetary_system_risk_score"] >= 0.40,
        ],
        [
            "Severe planetary system risk",
            "High planetary system risk",
            "Moderate planetary system risk",
        ],
        default="Lower planetary system risk",
    )

    df["resilience_warning"] = np.select(
        [
            df["planetary_pressure_score"] - df["response_capacity_score"] >= 0.35,
            df["planetary_pressure_score"] - df["response_capacity_score"] >= 0.20,
            df["planetary_pressure_score"] - df["response_capacity_score"] >= 0.05,
        ],
        [
            "Severe Earth-system resilience deficit",
            "High Earth-system resilience deficit",
            "Moderate Earth-system resilience deficit",
        ],
        default="Lower deficit or stronger response capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for planetary boundary risk review."""
    columns = [
        "boundary_name",
        "earth_system_domain",
        "boundary_status",
        "planetary_pressure_score",
        "response_capacity_score",
        "planetary_system_risk_score",
        "earth_system_resilience_margin",
        "risk_band",
        "resilience_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "planetary_system_risk_score",
                "planetary_pressure_score",
                "earth_system_resilience_margin",
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

    print("Planetary boundary risk scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

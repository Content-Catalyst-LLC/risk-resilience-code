from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/nonlinear_shock_propagation_panel.csv"
OUTPUT_FILE = "../outputs/nonlinear_shock_propagation_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a nonlinear shock-propagation dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "shock_type",
        "shock_intensity_index",
        "threshold_proximity_index",
        "network_centrality_index",
        "coupling_strength_index",
        "feedback_amplification_index",
        "hidden_stress_index",
        "exposure_inequality_index",
        "buffering_capacity_index",
        "modularity_index",
        "redundancy_index",
        "adaptive_response_index",
        "governance_quality_index",
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
    Compute propagation pressure, containment capacity,
    nonlinear propagation risk, and resilience margin.
    """
    df = df.copy()

    df["propagation_pressure_score"] = (
        0.16 * df["shock_intensity_index"]
        + 0.18 * df["threshold_proximity_index"]
        + 0.16 * df["network_centrality_index"]
        + 0.16 * df["coupling_strength_index"]
        + 0.14 * df["feedback_amplification_index"]
        + 0.10 * df["hidden_stress_index"]
        + 0.10 * df["exposure_inequality_index"]
    ).clip(lower=0, upper=1)

    df["containment_capacity_score"] = (
        0.22 * df["buffering_capacity_index"]
        + 0.20 * df["modularity_index"]
        + 0.20 * df["redundancy_index"]
        + 0.20 * df["adaptive_response_index"]
        + 0.18 * df["governance_quality_index"]
    ).clip(lower=0, upper=1)

    df["nonlinear_propagation_risk_score"] = (
        0.74 * df["propagation_pressure_score"]
        - 0.26 * df["containment_capacity_score"]
    ).clip(lower=0, upper=1)

    df["propagation_resilience_margin"] = (
        df["containment_capacity_score"]
        - df["propagation_pressure_score"]
    )

    df["propagation_band"] = np.select(
        [
            df["nonlinear_propagation_risk_score"] >= 0.80,
            df["nonlinear_propagation_risk_score"] >= 0.60,
            df["nonlinear_propagation_risk_score"] >= 0.40,
        ],
        [
            "Severe nonlinear propagation risk",
            "High nonlinear propagation risk",
            "Moderate nonlinear propagation risk",
        ],
        default="Lower nonlinear propagation risk",
    )

    df["containment_warning"] = np.select(
        [
            df["propagation_pressure_score"] - df["containment_capacity_score"] >= 0.35,
            df["propagation_pressure_score"] - df["containment_capacity_score"] >= 0.20,
            df["propagation_pressure_score"] - df["containment_capacity_score"] >= 0.05,
        ],
        [
            "Severe containment deficit",
            "High containment deficit",
            "Moderate containment deficit",
        ],
        default="Lower deficit or stronger containment capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for nonlinear shock-propagation review."""
    columns = [
        "system_name",
        "sector",
        "shock_type",
        "propagation_pressure_score",
        "containment_capacity_score",
        "nonlinear_propagation_risk_score",
        "propagation_resilience_margin",
        "propagation_band",
        "containment_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "nonlinear_propagation_risk_score",
                "propagation_pressure_score",
                "propagation_resilience_margin",
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

    print("Nonlinear shock-propagation scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

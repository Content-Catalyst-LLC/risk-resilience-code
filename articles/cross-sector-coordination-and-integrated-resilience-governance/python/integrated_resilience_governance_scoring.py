from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/integrated_resilience_governance_panel.csv"
OUTPUT_FILE = "../outputs/integrated_resilience_governance_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an integrated resilience governance dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "jurisdiction",
        "governance_system",
        "primary_risk_domain",
        "cross_sector_coordination_index",
        "dependency_visibility_index",
        "governance_integration_index",
        "data_interoperability_index",
        "public_accountability_index",
        "justice_equity_index",
        "local_capability_index",
        "adaptive_learning_index",
        "investment_alignment_index",
        "fragmentation_risk_index",
        "mandate_conflict_index",
        "governance_data_gap_index",
        "maladaptation_risk_index",
        "private_operator_opacity_index",
        "accountability_diffusion_index",
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
    Compute integrated governance capacity, coordination fragility pressure,
    and an integrated resilience governance gap.
    """
    df = df.copy()

    df["integrated_governance_capacity_score"] = (
        0.16 * df["cross_sector_coordination_index"] +
        0.14 * df["dependency_visibility_index"] +
        0.13 * df["governance_integration_index"] +
        0.11 * df["data_interoperability_index"] +
        0.11 * df["public_accountability_index"] +
        0.10 * df["justice_equity_index"] +
        0.09 * df["local_capability_index"] +
        0.08 * df["adaptive_learning_index"] +
        0.08 * df["investment_alignment_index"]
    ).clip(lower=0, upper=1)

    df["coordination_fragility_pressure_score"] = (
        0.19 * df["fragmentation_risk_index"] +
        0.17 * df["mandate_conflict_index"] +
        0.17 * df["governance_data_gap_index"] +
        0.16 * df["maladaptation_risk_index"] +
        0.15 * df["private_operator_opacity_index"] +
        0.16 * df["accountability_diffusion_index"]
    ).clip(lower=0, upper=1)

    df["integrated_resilience_governance_gap"] = (
        df["integrated_governance_capacity_score"] -
        df["coordination_fragility_pressure_score"]
    )

    df["governance_readiness_band"] = np.select(
        [
            df["integrated_governance_capacity_score"] >= 0.80,
            df["integrated_governance_capacity_score"] >= 0.60,
            df["integrated_governance_capacity_score"] >= 0.40,
        ],
        [
            "Strong integrated resilience governance capacity",
            "Moderate integrated resilience governance capacity",
            "Limited integrated resilience governance capacity",
        ],
        default="Weak integrated resilience governance capacity",
    )

    df["coordination_warning"] = np.select(
        [
            df["coordination_fragility_pressure_score"] - df["integrated_governance_capacity_score"] >= 0.35,
            df["coordination_fragility_pressure_score"] - df["integrated_governance_capacity_score"] >= 0.20,
            df["coordination_fragility_pressure_score"] - df["integrated_governance_capacity_score"] >= 0.05,
        ],
        [
            "Severe coordination fragility pressure",
            "High coordination fragility pressure",
            "Moderate coordination fragility pressure",
        ],
        default="Lower coordination fragility pressure or stronger governance capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for integrated resilience governance review."""
    columns = [
        "jurisdiction",
        "governance_system",
        "primary_risk_domain",
        "integrated_governance_capacity_score",
        "coordination_fragility_pressure_score",
        "integrated_resilience_governance_gap",
        "governance_readiness_band",
        "coordination_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "integrated_resilience_governance_gap",
                "integrated_governance_capacity_score",
                "coordination_fragility_pressure_score",
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

    print("Integrated resilience governance scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

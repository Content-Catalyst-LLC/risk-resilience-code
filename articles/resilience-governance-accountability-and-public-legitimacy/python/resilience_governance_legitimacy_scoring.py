from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_governance_legitimacy_panel.csv"
OUTPUT_FILE = "../outputs/resilience_governance_legitimacy_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a resilience-governance and legitimacy dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "institution_or_system",
        "jurisdiction",
        "risk_domain",
        "adaptive_capacity_index",
        "accountability_capacity_index",
        "public_legitimacy_index",
        "transparency_index",
        "participation_strength_index",
        "coordination_capacity_index",
        "learning_capacity_index",
        "institutional_memory_index",
        "justice_orientation_index",
        "oversight_strength_index",
        "remedy_availability_index",
        "correction_capacity_index",
        "fragmentation_index",
        "capture_risk_index",
        "trust_erosion_index",
        "vulnerability_exposure_index",
        "systemic_risk_exposure_index",
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
    Compute resilience governance quality, accountability-legitimacy capacity,
    governance vulnerability, and legitimate resilience governance.
    """
    df = df.copy()

    df["resilience_governance_quality_score"] = (
        0.11 * df["adaptive_capacity_index"] +
        0.11 * df["accountability_capacity_index"] +
        0.10 * df["public_legitimacy_index"] +
        0.09 * df["transparency_index"] +
        0.09 * df["participation_strength_index"] +
        0.09 * df["coordination_capacity_index"] +
        0.09 * df["learning_capacity_index"] +
        0.08 * df["institutional_memory_index"] +
        0.08 * df["justice_orientation_index"] +
        0.08 * df["oversight_strength_index"] +
        0.08 * df["correction_capacity_index"]
    ).clip(lower=0, upper=1)

    df["accountability_legitimacy_capacity_score"] = (
        0.16 * df["accountability_capacity_index"] +
        0.14 * df["public_legitimacy_index"] +
        0.13 * df["transparency_index"] +
        0.12 * df["oversight_strength_index"] +
        0.12 * df["remedy_availability_index"] +
        0.12 * df["correction_capacity_index"] +
        0.11 * df["participation_strength_index"] +
        0.10 * df["justice_orientation_index"]
    ).clip(lower=0, upper=1)

    df["governance_vulnerability_score"] = (
        0.17 * df["fragmentation_index"] +
        0.16 * df["capture_risk_index"] +
        0.15 * df["trust_erosion_index"] +
        0.14 * df["vulnerability_exposure_index"] +
        0.13 * df["systemic_risk_exposure_index"] +
        0.09 * (1 - df["accountability_capacity_index"]) +
        0.08 * (1 - df["transparency_index"]) +
        0.08 * (1 - df["learning_capacity_index"])
    ).clip(lower=0, upper=1)

    df["legitimate_resilience_governance_score"] = (
        0.38 * df["resilience_governance_quality_score"] +
        0.32 * df["accountability_legitimacy_capacity_score"] +
        0.18 * (1 - df["governance_vulnerability_score"]) +
        0.12 * df["justice_orientation_index"]
    ).clip(lower=0, upper=1)

    df["legitimacy_gap"] = (
        df["accountability_legitimacy_capacity_score"] -
        df["governance_vulnerability_score"]
    )

    df["governance_band"] = np.select(
        [
            df["legitimate_resilience_governance_score"] >= 0.80,
            df["legitimate_resilience_governance_score"] >= 0.60,
            df["legitimate_resilience_governance_score"] >= 0.40,
        ],
        [
            "Strong legitimate resilience governance",
            "Moderate legitimate resilience governance",
            "Limited legitimate resilience governance",
        ],
        default="Weak legitimate resilience governance",
    )

    df["accountability_warning"] = np.select(
        [
            df["governance_vulnerability_score"] - df["accountability_legitimacy_capacity_score"] >= 0.35,
            df["governance_vulnerability_score"] - df["accountability_legitimacy_capacity_score"] >= 0.20,
            df["governance_vulnerability_score"] - df["accountability_legitimacy_capacity_score"] >= 0.05,
        ],
        [
            "Severe accountability-legitimacy gap",
            "High accountability-legitimacy gap",
            "Moderate accountability-legitimacy gap",
        ],
        default="Lower accountability-legitimacy gap or stronger governance capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for resilience-governance review."""
    columns = [
        "institution_or_system",
        "jurisdiction",
        "risk_domain",
        "resilience_governance_quality_score",
        "accountability_legitimacy_capacity_score",
        "governance_vulnerability_score",
        "legitimate_resilience_governance_score",
        "legitimacy_gap",
        "governance_band",
        "accountability_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "legitimate_resilience_governance_score",
                "accountability_legitimacy_capacity_score",
                "governance_vulnerability_score",
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

    print("Resilience governance, accountability, and legitimacy scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

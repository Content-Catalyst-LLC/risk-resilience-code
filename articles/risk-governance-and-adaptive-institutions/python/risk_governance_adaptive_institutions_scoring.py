from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/risk_governance_institutions_panel.csv"
OUTPUT_FILE = "../outputs/risk_governance_adaptive_institutions_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a risk-governance and adaptive-institutions dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "institution_or_system",
        "jurisdiction",
        "risk_domain",
        "anticipatory_capacity_index",
        "appraisal_quality_index",
        "coordination_capacity_index",
        "participation_strength_index",
        "transparency_index",
        "legitimacy_index",
        "learning_capacity_index",
        "institutional_memory_index",
        "justice_orientation_index",
        "monitoring_feedback_index",
        "policy_revision_capacity_index",
        "fragmentation_index",
        "uncertainty_load_index",
        "capture_risk_index",
        "systemic_risk_exposure_index",
        "vulnerability_exposure_index",
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
    Compute risk-governance quality, adaptive institutional capacity,
    governance vulnerability, and resilience governance.
    """
    df = df.copy()

    df["risk_governance_quality_score"] = (
        0.11 * df["anticipatory_capacity_index"] +
        0.11 * df["appraisal_quality_index"] +
        0.11 * df["coordination_capacity_index"] +
        0.10 * df["participation_strength_index"] +
        0.09 * df["transparency_index"] +
        0.10 * df["legitimacy_index"] +
        0.10 * df["learning_capacity_index"] +
        0.08 * df["institutional_memory_index"] +
        0.08 * df["justice_orientation_index"] +
        0.07 * df["monitoring_feedback_index"] +
        0.05 * df["policy_revision_capacity_index"]
    ).clip(lower=0, upper=1)

    df["adaptive_institutional_capacity_score"] = (
        0.16 * df["monitoring_feedback_index"] +
        0.15 * df["policy_revision_capacity_index"] +
        0.15 * df["coordination_capacity_index"] +
        0.14 * df["learning_capacity_index"] +
        0.12 * df["institutional_memory_index"] +
        0.11 * df["participation_strength_index"] +
        0.09 * df["legitimacy_index"] +
        0.08 * df["justice_orientation_index"]
    ).clip(lower=0, upper=1)

    df["governance_vulnerability_score"] = (
        0.18 * df["fragmentation_index"] +
        0.16 * df["uncertainty_load_index"] +
        0.15 * df["capture_risk_index"] +
        0.14 * df["systemic_risk_exposure_index"] +
        0.12 * df["vulnerability_exposure_index"] +
        0.09 * (1 - df["coordination_capacity_index"]) +
        0.08 * (1 - df["transparency_index"]) +
        0.08 * (1 - df["learning_capacity_index"])
    ).clip(lower=0, upper=1)

    df["resilience_governance_score"] = (
        0.40 * df["risk_governance_quality_score"] +
        0.32 * df["adaptive_institutional_capacity_score"] +
        0.18 * (1 - df["governance_vulnerability_score"]) +
        0.10 * df["justice_orientation_index"]
    ).clip(lower=0, upper=1)

    df["capacity_gap"] = (
        df["risk_governance_quality_score"] -
        df["governance_vulnerability_score"]
    )

    df["governance_band"] = np.select(
        [
            df["resilience_governance_score"] >= 0.80,
            df["resilience_governance_score"] >= 0.60,
            df["resilience_governance_score"] >= 0.40,
        ],
        [
            "Strong adaptive risk governance",
            "Moderate adaptive risk governance",
            "Limited adaptive risk governance",
        ],
        default="Weak adaptive risk governance",
    )

    df["institutional_warning"] = np.select(
        [
            df["governance_vulnerability_score"] - df["risk_governance_quality_score"] >= 0.35,
            df["governance_vulnerability_score"] - df["risk_governance_quality_score"] >= 0.20,
            df["governance_vulnerability_score"] - df["risk_governance_quality_score"] >= 0.05,
        ],
        [
            "Severe governance-capacity gap",
            "High governance-capacity gap",
            "Moderate governance-capacity gap",
        ],
        default="Lower governance-capacity gap or stronger adaptive capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for risk-governance review."""
    columns = [
        "institution_or_system",
        "jurisdiction",
        "risk_domain",
        "risk_governance_quality_score",
        "adaptive_institutional_capacity_score",
        "governance_vulnerability_score",
        "resilience_governance_score",
        "capacity_gap",
        "governance_band",
        "institutional_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_governance_score",
                "risk_governance_quality_score",
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

    print("Risk governance and adaptive institutions scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

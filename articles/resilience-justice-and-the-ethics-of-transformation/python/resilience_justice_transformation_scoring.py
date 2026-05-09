from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_justice_transformation_panel.csv"
OUTPUT_FILE = "../outputs/resilience_justice_transformation_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a resilience, justice, and transformation dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "initiative_name",
        "jurisdiction",
        "transformation_domain",
        "technical_resilience_index",
        "distributive_justice_index",
        "procedural_justice_index",
        "recognition_index",
        "rights_protection_index",
        "institutional_accountability_index",
        "ecological_governance_index",
        "intergenerational_responsibility_index",
        "public_legitimacy_index",
        "data_transparency_index",
        "maladaptation_risk_index",
        "harm_shifting_risk_index",
        "exclusion_risk_index",
        "coercion_risk_index",
        "displacement_risk_index",
        "unequal_burden_index",
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
    Compute justice-oriented transformation, ethical risk pressure,
    legitimacy-adjusted transformation, and the resilience justice gap.
    """
    df = df.copy()

    df["justice_oriented_transformation_score"] = (
        0.16 * df["distributive_justice_index"] +
        0.15 * df["procedural_justice_index"] +
        0.13 * df["recognition_index"] +
        0.13 * df["rights_protection_index"] +
        0.12 * df["institutional_accountability_index"] +
        0.10 * df["ecological_governance_index"] +
        0.09 * df["intergenerational_responsibility_index"] +
        0.07 * df["public_legitimacy_index"] +
        0.05 * df["data_transparency_index"]
    ).clip(lower=0, upper=1)

    df["ethical_risk_pressure_score"] = (
        0.20 * df["maladaptation_risk_index"] +
        0.18 * df["harm_shifting_risk_index"] +
        0.17 * df["exclusion_risk_index"] +
        0.15 * df["coercion_risk_index"] +
        0.15 * df["displacement_risk_index"] +
        0.15 * df["unequal_burden_index"]
    ).clip(lower=0, upper=1)

    df["legitimacy_adjusted_transformation_score"] = (
        0.45 * df["justice_oriented_transformation_score"] +
        0.20 * df["technical_resilience_index"] +
        0.15 * df["public_legitimacy_index"] +
        0.10 * df["data_transparency_index"] +
        0.10 * (1 - df["ethical_risk_pressure_score"])
    ).clip(lower=0, upper=1)

    df["resilience_justice_gap"] = (
        df["legitimacy_adjusted_transformation_score"] -
        df["ethical_risk_pressure_score"]
    )

    df["technical_justice_gap"] = (
        df["technical_resilience_index"] -
        df["justice_oriented_transformation_score"]
    )

    df["justice_band"] = np.select(
        [
            df["legitimacy_adjusted_transformation_score"] >= 0.80,
            df["legitimacy_adjusted_transformation_score"] >= 0.60,
            df["legitimacy_adjusted_transformation_score"] >= 0.40,
        ],
        [
            "Strong justice-oriented transformation",
            "Moderate justice-oriented transformation",
            "Limited justice-oriented transformation",
        ],
        default="Weak justice-oriented transformation",
    )

    df["ethical_warning"] = np.select(
        [
            df["ethical_risk_pressure_score"] - df["legitimacy_adjusted_transformation_score"] >= 0.35,
            df["ethical_risk_pressure_score"] - df["legitimacy_adjusted_transformation_score"] >= 0.20,
            df["ethical_risk_pressure_score"] - df["legitimacy_adjusted_transformation_score"] >= 0.05,
        ],
        [
            "Severe ethical transformation gap",
            "High ethical transformation gap",
            "Moderate ethical transformation gap",
        ],
        default="Lower ethical risk or stronger justice-oriented transformation",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for justice and transformation review."""
    columns = [
        "initiative_name",
        "jurisdiction",
        "transformation_domain",
        "technical_resilience_index",
        "justice_oriented_transformation_score",
        "ethical_risk_pressure_score",
        "legitimacy_adjusted_transformation_score",
        "resilience_justice_gap",
        "technical_justice_gap",
        "justice_band",
        "ethical_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_justice_gap",
                "legitimacy_adjusted_transformation_score",
                "ethical_risk_pressure_score",
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

    print("Resilience, justice, and transformation scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

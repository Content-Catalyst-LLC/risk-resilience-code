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
        "risk_management_capacity_index",
        "ecological_restoration_index",
        "social_capacity_index",
        "institutional_learning_index",
        "justice_orientation_index",
        "long_term_investment_index",
        "livelihood_viability_index",
        "ecological_function_index",
        "public_trust_index",
        "adaptive_governance_index",
        "community_participation_index",
        "regenerative_finance_index",
        "depletion_pressure_index",
        "maladaptation_risk_index",
        "extractive_pressure_index",
        "institutional_fatigue_index",
        "chronic_vulnerability_index",
        "recovery_only_bias_index",
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
    Compute defensive risk-management capacity, regenerative capacity,
    depletion pressure, renewal balance, and regenerative resilience.
    """
    df = df.copy()

    df["defensive_risk_management_score"] = (
        0.28 * df["risk_management_capacity_index"] +
        0.18 * df["adaptive_governance_index"] +
        0.16 * df["institutional_learning_index"] +
        0.14 * df["public_trust_index"] +
        0.12 * df["community_participation_index"] +
        0.12 * df["long_term_investment_index"]
    ).clip(lower=0, upper=1)

    df["regenerative_capacity_score"] = (
        0.16 * df["ecological_restoration_index"] +
        0.14 * df["ecological_function_index"] +
        0.14 * df["social_capacity_index"] +
        0.13 * df["institutional_learning_index"] +
        0.12 * df["justice_orientation_index"] +
        0.11 * df["livelihood_viability_index"] +
        0.10 * df["long_term_investment_index"] +
        0.10 * df["regenerative_finance_index"]
    ).clip(lower=0, upper=1)

    df["depletion_and_maladaptation_pressure_score"] = (
        0.18 * df["depletion_pressure_index"] +
        0.17 * df["maladaptation_risk_index"] +
        0.16 * df["extractive_pressure_index"] +
        0.15 * df["institutional_fatigue_index"] +
        0.14 * df["chronic_vulnerability_index"] +
        0.10 * df["recovery_only_bias_index"] +
        0.05 * (1 - df["ecological_function_index"]) +
        0.05 * (1 - df["justice_orientation_index"])
    ).clip(lower=0, upper=1)

    df["regenerative_resilience_score"] = (
        0.34 * df["regenerative_capacity_score"] +
        0.24 * df["defensive_risk_management_score"] +
        0.18 * (1 - df["depletion_and_maladaptation_pressure_score"]) +
        0.12 * df["justice_orientation_index"] +
        0.12 * df["ecological_function_index"]
    ).clip(lower=0, upper=1)

    df["renewal_balance"] = (
        df["regenerative_capacity_score"] -
        df["depletion_and_maladaptation_pressure_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["regenerative_resilience_score"] >= 0.80,
            df["regenerative_resilience_score"] >= 0.60,
            df["regenerative_resilience_score"] >= 0.40,
        ],
        [
            "Strong regenerative resilience",
            "Moderate regenerative resilience",
            "Limited regenerative resilience",
        ],
        default="Weak regenerative resilience",
    )

    df["regeneration_warning"] = np.select(
        [
            df["depletion_and_maladaptation_pressure_score"] - df["regenerative_capacity_score"] >= 0.35,
            df["depletion_and_maladaptation_pressure_score"] - df["regenerative_capacity_score"] >= 0.20,
            df["depletion_and_maladaptation_pressure_score"] - df["regenerative_capacity_score"] >= 0.05,
        ],
        [
            "Severe renewal deficit",
            "High renewal deficit",
            "Moderate renewal deficit",
        ],
        default="Lower renewal deficit or stronger regenerative capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for regenerative resilience review."""
    columns = [
        "system_name",
        "jurisdiction",
        "system_type",
        "defensive_risk_management_score",
        "regenerative_capacity_score",
        "depletion_and_maladaptation_pressure_score",
        "regenerative_resilience_score",
        "renewal_balance",
        "resilience_band",
        "regeneration_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "regenerative_resilience_score",
                "regenerative_capacity_score",
                "depletion_and_maladaptation_pressure_score",
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

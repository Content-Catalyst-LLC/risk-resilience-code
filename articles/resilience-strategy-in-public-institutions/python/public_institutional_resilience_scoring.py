from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/public_institutional_resilience_panel.csv"
OUTPUT_FILE = "../outputs/public_institutional_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a public institutional resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "institution_name",
        "jurisdiction",
        "institution_type",
        "primary_service_domain",
        "anticipatory_foresight_index",
        "continuity_operations_index",
        "administrative_capacity_index",
        "coordination_capacity_index",
        "risk_informed_finance_index",
        "procurement_resilience_index",
        "digital_fallback_index",
        "public_legitimacy_index",
        "justice_service_equity_index",
        "learning_adaptation_index",
        "fragmentation_risk_index",
        "underinvestment_risk_index",
        "staffing_fragility_index",
        "digital_dependency_risk_index",
        "procurement_vulnerability_index",
        "accountability_gap_index",
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
    Compute institutional resilience capacity, institutional fragility pressure,
    legitimacy-adjusted resilience, and resilience gap.
    """
    df = df.copy()

    df["institutional_resilience_capacity_score"] = (
        0.13 * df["anticipatory_foresight_index"] +
        0.13 * df["continuity_operations_index"] +
        0.12 * df["administrative_capacity_index"] +
        0.11 * df["coordination_capacity_index"] +
        0.10 * df["risk_informed_finance_index"] +
        0.10 * df["procurement_resilience_index"] +
        0.08 * df["digital_fallback_index"] +
        0.08 * df["public_legitimacy_index"] +
        0.08 * df["justice_service_equity_index"] +
        0.07 * df["learning_adaptation_index"]
    ).clip(lower=0, upper=1)

    df["institutional_fragility_pressure_score"] = (
        0.18 * df["fragmentation_risk_index"] +
        0.18 * df["underinvestment_risk_index"] +
        0.17 * df["staffing_fragility_index"] +
        0.16 * df["digital_dependency_risk_index"] +
        0.15 * df["procurement_vulnerability_index"] +
        0.16 * df["accountability_gap_index"]
    ).clip(lower=0, upper=1)

    df["legitimacy_adjusted_resilience_score"] = (
        0.50 * df["institutional_resilience_capacity_score"] +
        0.20 * df["public_legitimacy_index"] +
        0.15 * df["justice_service_equity_index"] +
        0.15 * (1 - df["accountability_gap_index"])
    ).clip(lower=0, upper=1)

    df["institutional_resilience_gap"] = (
        df["legitimacy_adjusted_resilience_score"] -
        df["institutional_fragility_pressure_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["legitimacy_adjusted_resilience_score"] >= 0.80,
            df["legitimacy_adjusted_resilience_score"] >= 0.60,
            df["legitimacy_adjusted_resilience_score"] >= 0.40,
        ],
        [
            "Strong public institutional resilience",
            "Moderate public institutional resilience",
            "Limited public institutional resilience",
        ],
        default="Weak public institutional resilience",
    )

    df["institutional_warning"] = np.select(
        [
            df["institutional_fragility_pressure_score"] - df["legitimacy_adjusted_resilience_score"] >= 0.35,
            df["institutional_fragility_pressure_score"] - df["legitimacy_adjusted_resilience_score"] >= 0.20,
            df["institutional_fragility_pressure_score"] - df["legitimacy_adjusted_resilience_score"] >= 0.05,
        ],
        [
            "Severe institutional resilience gap",
            "High institutional resilience gap",
            "Moderate institutional resilience gap",
        ],
        default="Lower fragility pressure or stronger institutional resilience",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for public institutional resilience review."""
    columns = [
        "institution_name",
        "jurisdiction",
        "institution_type",
        "primary_service_domain",
        "institutional_resilience_capacity_score",
        "institutional_fragility_pressure_score",
        "legitimacy_adjusted_resilience_score",
        "institutional_resilience_gap",
        "resilience_band",
        "institutional_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "institutional_resilience_gap",
                "legitimacy_adjusted_resilience_score",
                "institutional_fragility_pressure_score",
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

    print("Public institutional resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

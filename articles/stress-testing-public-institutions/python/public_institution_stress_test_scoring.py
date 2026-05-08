from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/public_institution_stress_test_panel.csv"
OUTPUT_FILE = "../outputs/public_institution_stress_test_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a public-institution stress-test dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "institution_or_system",
        "jurisdiction",
        "public_function",
        "essential_function_clarity_index",
        "capacity_margin_index",
        "dependency_visibility_index",
        "workforce_resilience_index",
        "digital_resilience_index",
        "legal_authority_clarity_index",
        "coordination_capacity_index",
        "equity_protection_index",
        "public_trust_index",
        "recovery_capacity_index",
        "backup_systems_index",
        "mutual_aid_capacity_index",
        "fiscal_reserve_capacity_index",
        "learning_capacity_index",
        "accountability_mechanism_index",
        "overload_pressure_index",
        "institutional_fragmentation_index",
        "hidden_fragility_index",
        "vendor_dependency_index",
        "compound_stress_exposure_index",
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
    Compute stress readiness, stress vulnerability,
    recovery capacity, and resilience-adjusted stress risk.
    """
    df = df.copy()

    df["stress_readiness_score"] = (
        0.10 * df["essential_function_clarity_index"] +
        0.10 * df["capacity_margin_index"] +
        0.09 * df["dependency_visibility_index"] +
        0.09 * df["workforce_resilience_index"] +
        0.09 * df["digital_resilience_index"] +
        0.08 * df["legal_authority_clarity_index"] +
        0.09 * df["coordination_capacity_index"] +
        0.09 * df["equity_protection_index"] +
        0.08 * df["public_trust_index"] +
        0.07 * df["recovery_capacity_index"] +
        0.06 * df["learning_capacity_index"] +
        0.06 * df["accountability_mechanism_index"]
    ).clip(lower=0, upper=1)

    df["stress_vulnerability_score"] = (
        0.15 * df["overload_pressure_index"] +
        0.14 * df["institutional_fragmentation_index"] +
        0.14 * df["hidden_fragility_index"] +
        0.13 * df["vendor_dependency_index"] +
        0.13 * df["compound_stress_exposure_index"] +
        0.09 * (1 - df["capacity_margin_index"]) +
        0.08 * (1 - df["dependency_visibility_index"]) +
        0.07 * (1 - df["digital_resilience_index"]) +
        0.07 * (1 - df["workforce_resilience_index"]) +
        0.06 * (1 - df["public_trust_index"])
    ).clip(lower=0, upper=1)

    df["institutional_recovery_score"] = (
        0.18 * df["recovery_capacity_index"] +
        0.16 * df["backup_systems_index"] +
        0.15 * df["mutual_aid_capacity_index"] +
        0.15 * df["fiscal_reserve_capacity_index"] +
        0.14 * df["learning_capacity_index"] +
        0.12 * df["accountability_mechanism_index"] +
        0.10 * df["coordination_capacity_index"]
    ).clip(lower=0, upper=1)

    df["resilience_adjusted_stress_risk"] = (
        0.36 * df["stress_vulnerability_score"] +
        0.24 * (1 - df["stress_readiness_score"]) +
        0.18 * (1 - df["institutional_recovery_score"]) +
        0.12 * df["compound_stress_exposure_index"] +
        0.10 * (1 - df["equity_protection_index"])
    ).clip(lower=0, upper=1)

    df["readiness_gap"] = (
        df["stress_readiness_score"] -
        df["stress_vulnerability_score"]
    )

    df["risk_band"] = np.select(
        [
            df["resilience_adjusted_stress_risk"] >= 0.80,
            df["resilience_adjusted_stress_risk"] >= 0.60,
            df["resilience_adjusted_stress_risk"] >= 0.40,
        ],
        [
            "Extreme public-institution stress risk",
            "High public-institution stress risk",
            "Moderate public-institution stress risk",
        ],
        default="Lower public-institution stress risk",
    )

    df["stress_warning"] = np.select(
        [
            df["stress_vulnerability_score"] - df["stress_readiness_score"] >= 0.35,
            df["stress_vulnerability_score"] - df["stress_readiness_score"] >= 0.20,
            df["stress_vulnerability_score"] - df["stress_readiness_score"] >= 0.05,
        ],
        [
            "Severe stress-readiness gap",
            "High stress-readiness gap",
            "Moderate stress-readiness gap",
        ],
        default="Lower stress-readiness gap or stronger readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for public-institution stress review."""
    columns = [
        "institution_or_system",
        "jurisdiction",
        "public_function",
        "stress_readiness_score",
        "stress_vulnerability_score",
        "institutional_recovery_score",
        "resilience_adjusted_stress_risk",
        "readiness_gap",
        "risk_band",
        "stress_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_adjusted_stress_risk",
                "stress_vulnerability_score",
                "stress_readiness_score",
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

    print("Public-institution stress-test scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

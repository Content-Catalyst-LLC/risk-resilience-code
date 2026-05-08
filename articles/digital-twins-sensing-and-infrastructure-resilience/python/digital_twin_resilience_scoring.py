from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/digital_twin_infrastructure_panel.csv"
OUTPUT_FILE = "../outputs/digital_twin_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an infrastructure digital twin assessment dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "infrastructure_type",
        "sensing_coverage_index",
        "data_quality_index",
        "data_timeliness_index",
        "model_validation_index",
        "decision_integration_index",
        "dependency_visibility_index",
        "predictive_maintenance_usefulness_index",
        "climate_adaptation_usefulness_index",
        "service_continuity_relevance_index",
        "cyber_risk_index",
        "platform_dependency_index",
        "model_uncertainty_index",
        "equity_coverage_index",
        "governance_capacity_index",
        "public_accountability_index",
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
    Compute digital twin resilience contribution, implementation risk,
    and resilience-readiness score.
    """
    df = df.copy()

    df["digital_twin_resilience_contribution"] = (
        0.13 * df["sensing_coverage_index"] +
        0.12 * df["data_quality_index"] +
        0.09 * df["data_timeliness_index"] +
        0.13 * df["model_validation_index"] +
        0.13 * df["decision_integration_index"] +
        0.10 * df["dependency_visibility_index"] +
        0.10 * df["predictive_maintenance_usefulness_index"] +
        0.08 * df["climate_adaptation_usefulness_index"] +
        0.06 * df["equity_coverage_index"] +
        0.06 * df["governance_capacity_index"]
    ).clip(lower=0, upper=1)

    df["digital_twin_implementation_risk"] = (
        0.18 * df["cyber_risk_index"] +
        0.15 * df["platform_dependency_index"] +
        0.15 * df["model_uncertainty_index"] +
        0.12 * (1 - df["model_validation_index"]) +
        0.12 * (1 - df["data_quality_index"]) +
        0.10 * (1 - df["governance_capacity_index"]) +
        0.09 * (1 - df["public_accountability_index"]) +
        0.09 * (1 - df["equity_coverage_index"])
    ).clip(lower=0, upper=1)

    df["resilience_readiness_score"] = (
        0.42 * df["digital_twin_resilience_contribution"] +
        0.22 * (1 - df["digital_twin_implementation_risk"]) +
        0.14 * df["service_continuity_relevance_index"] +
        0.12 * df["governance_capacity_index"] +
        0.10 * df["public_accountability_index"]
    ).clip(lower=0, upper=1)

    df["resilience_gap"] = (
        df["digital_twin_resilience_contribution"] -
        df["digital_twin_implementation_risk"]
    )

    df["readiness_band"] = np.select(
        [
            df["resilience_readiness_score"] >= 0.80,
            df["resilience_readiness_score"] >= 0.60,
            df["resilience_readiness_score"] >= 0.40,
        ],
        [
            "Strong digital twin resilience readiness",
            "Moderate digital twin resilience readiness",
            "Limited digital twin resilience readiness",
        ],
        default="Weak digital twin resilience readiness",
    )

    df["implementation_warning"] = np.select(
        [
            df["digital_twin_implementation_risk"] >= 0.75,
            df["digital_twin_implementation_risk"] >= 0.55,
            df["digital_twin_implementation_risk"] >= 0.35,
        ],
        [
            "Severe implementation and trust risk",
            "High implementation and trust risk",
            "Moderate implementation and trust risk",
        ],
        default="Lower implementation and trust risk",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for digital twin resilience review."""
    columns = [
        "system_name",
        "sector",
        "infrastructure_type",
        "digital_twin_resilience_contribution",
        "digital_twin_implementation_risk",
        "resilience_readiness_score",
        "resilience_gap",
        "readiness_band",
        "implementation_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_readiness_score",
                "digital_twin_resilience_contribution",
                "digital_twin_implementation_risk",
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

    print("Digital twin resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

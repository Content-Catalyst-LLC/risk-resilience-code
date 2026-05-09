from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_dashboard_blind_spots_panel.csv"
OUTPUT_FILE = "../outputs/resilience_dashboard_blind_spot_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a resilience dashboard diagnostic dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "dashboard_name",
        "jurisdiction",
        "dashboard_type",
        "indicator_coverage_index",
        "dashboard_usability_index",
        "data_quality_index",
        "update_frequency_index",
        "disaggregation_strength_index",
        "equity_visibility_index",
        "uncertainty_transparency_index",
        "action_linkage_index",
        "community_validation_index",
        "governance_accountability_index",
        "threshold_clarity_index",
        "stress_performance_integration_index",
        "false_precision_risk_index",
        "proxy_dependence_index",
        "missing_data_risk_index",
        "aggregation_loss_index",
        "scale_boundary_error_index",
        "dashboard_theater_risk_index",
        "blind_spot_severity_index",
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
    Compute dashboard strength, blind-spot risk,
    actionability, and equity-adjusted dashboard reliability.
    """
    df = df.copy()

    df["dashboard_strength_score"] = (
        0.12 * df["indicator_coverage_index"] +
        0.10 * df["dashboard_usability_index"] +
        0.11 * df["data_quality_index"] +
        0.08 * df["update_frequency_index"] +
        0.11 * df["disaggregation_strength_index"] +
        0.10 * df["equity_visibility_index"] +
        0.10 * df["uncertainty_transparency_index"] +
        0.10 * df["action_linkage_index"] +
        0.08 * df["community_validation_index"] +
        0.10 * df["governance_accountability_index"] +
        0.05 * df["threshold_clarity_index"] +
        0.05 * df["stress_performance_integration_index"]
    ).clip(lower=0, upper=1)

    df["blind_spot_risk_score"] = (
        0.16 * df["false_precision_risk_index"] +
        0.15 * df["proxy_dependence_index"] +
        0.15 * df["missing_data_risk_index"] +
        0.14 * df["aggregation_loss_index"] +
        0.13 * df["scale_boundary_error_index"] +
        0.13 * df["dashboard_theater_risk_index"] +
        0.14 * df["blind_spot_severity_index"]
    ).clip(lower=0, upper=1)

    df["dashboard_actionability_score"] = (
        0.24 * df["action_linkage_index"] +
        0.20 * df["governance_accountability_index"] +
        0.18 * df["threshold_clarity_index"] +
        0.16 * df["stress_performance_integration_index"] +
        0.12 * df["update_frequency_index"] +
        0.10 * df["dashboard_usability_index"]
    ).clip(lower=0, upper=1)

    df["equity_adjusted_dashboard_reliability_score"] = (
        0.34 * df["dashboard_strength_score"] +
        0.24 * df["dashboard_actionability_score"] +
        0.18 * (1 - df["blind_spot_risk_score"]) +
        0.14 * df["equity_visibility_index"] +
        0.10 * df["community_validation_index"]
    ).clip(lower=0, upper=1)

    df["dashboard_reliability_gap"] = (
        df["dashboard_strength_score"] -
        df["blind_spot_risk_score"]
    )

    df["dashboard_band"] = np.select(
        [
            df["equity_adjusted_dashboard_reliability_score"] >= 0.80,
            df["equity_adjusted_dashboard_reliability_score"] >= 0.60,
            df["equity_adjusted_dashboard_reliability_score"] >= 0.40,
        ],
        [
            "Strong resilience dashboard reliability",
            "Moderate resilience dashboard reliability",
            "Limited resilience dashboard reliability",
        ],
        default="Weak resilience dashboard reliability",
    )

    df["blind_spot_warning"] = np.select(
        [
            df["blind_spot_risk_score"] - df["dashboard_strength_score"] >= 0.35,
            df["blind_spot_risk_score"] - df["dashboard_strength_score"] >= 0.20,
            df["blind_spot_risk_score"] - df["dashboard_strength_score"] >= 0.05,
        ],
        [
            "Severe dashboard blind-spot risk",
            "High dashboard blind-spot risk",
            "Moderate dashboard blind-spot risk",
        ],
        default="Lower dashboard blind-spot risk or stronger dashboard reliability",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for resilience dashboard review."""
    columns = [
        "dashboard_name",
        "jurisdiction",
        "dashboard_type",
        "dashboard_strength_score",
        "blind_spot_risk_score",
        "dashboard_actionability_score",
        "equity_adjusted_dashboard_reliability_score",
        "dashboard_reliability_gap",
        "dashboard_band",
        "blind_spot_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "equity_adjusted_dashboard_reliability_score",
                "dashboard_actionability_score",
                "blind_spot_risk_score",
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

    print("Resilience dashboard blind-spot diagnostics complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

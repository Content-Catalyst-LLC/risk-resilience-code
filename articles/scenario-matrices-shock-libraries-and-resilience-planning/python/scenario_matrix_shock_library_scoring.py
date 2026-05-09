from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/scenario_matrix_shock_library_panel.csv"
OUTPUT_FILE = "../outputs/scenario_matrix_resilience_planning_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a scenario matrix and shock-library planning dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "planning_system",
        "jurisdiction",
        "system_type",
        "scenario_coverage_index",
        "shock_library_quality_index",
        "shock_specificity_index",
        "compound_risk_coverage_index",
        "essential_function_mapping_index",
        "dependency_mapping_index",
        "trigger_readiness_index",
        "threshold_clarity_index",
        "equity_integration_index",
        "community_validation_index",
        "stress_test_linkage_index",
        "governance_ownership_index",
        "update_cadence_index",
        "action_linkage_index",
        "adaptive_decision_capacity_index",
        "compound_risk_exposure_index",
        "blind_spot_gap_index",
        "stale_assumption_risk_index",
        "scenario_theater_risk_index",
        "untested_fragility_index",
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
    Compute scenario matrix quality, shock-library reliability,
    planning actionability, blind-spot pressure, and resilience-planning readiness.
    """
    df = df.copy()

    df["scenario_matrix_quality_score"] = (
        0.16 * df["scenario_coverage_index"] +
        0.13 * df["compound_risk_coverage_index"] +
        0.13 * df["essential_function_mapping_index"] +
        0.12 * df["dependency_mapping_index"] +
        0.12 * df["trigger_readiness_index"] +
        0.11 * df["threshold_clarity_index"] +
        0.11 * df["equity_integration_index"] +
        0.12 * df["stress_test_linkage_index"]
    ).clip(lower=0, upper=1)

    df["shock_library_reliability_score"] = (
        0.18 * df["shock_library_quality_index"] +
        0.16 * df["shock_specificity_index"] +
        0.14 * df["compound_risk_coverage_index"] +
        0.13 * df["dependency_mapping_index"] +
        0.12 * df["essential_function_mapping_index"] +
        0.10 * df["community_validation_index"] +
        0.09 * df["update_cadence_index"] +
        0.08 * df["governance_ownership_index"]
    ).clip(lower=0, upper=1)

    df["planning_actionability_score"] = (
        0.20 * df["action_linkage_index"] +
        0.18 * df["governance_ownership_index"] +
        0.16 * df["trigger_readiness_index"] +
        0.14 * df["threshold_clarity_index"] +
        0.12 * df["stress_test_linkage_index"] +
        0.10 * df["adaptive_decision_capacity_index"] +
        0.10 * df["update_cadence_index"]
    ).clip(lower=0, upper=1)

    df["blind_spot_pressure_score"] = (
        0.22 * df["compound_risk_exposure_index"] +
        0.20 * df["blind_spot_gap_index"] +
        0.18 * df["stale_assumption_risk_index"] +
        0.16 * df["scenario_theater_risk_index"] +
        0.14 * df["untested_fragility_index"] +
        0.10 * (1 - df["community_validation_index"])
    ).clip(lower=0, upper=1)

    df["resilience_planning_readiness_score"] = (
        0.28 * df["scenario_matrix_quality_score"] +
        0.24 * df["shock_library_reliability_score"] +
        0.22 * df["planning_actionability_score"] +
        0.14 * df["adaptive_decision_capacity_index"] +
        0.12 * (1 - df["blind_spot_pressure_score"])
    ).clip(lower=0, upper=1)

    df["planning_readiness_gap"] = (
        df["resilience_planning_readiness_score"] -
        df["blind_spot_pressure_score"]
    )

    df["planning_band"] = np.select(
        [
            df["resilience_planning_readiness_score"] >= 0.80,
            df["resilience_planning_readiness_score"] >= 0.60,
            df["resilience_planning_readiness_score"] >= 0.40,
        ],
        [
            "Strong scenario-based resilience planning",
            "Moderate scenario-based resilience planning",
            "Limited scenario-based resilience planning",
        ],
        default="Weak scenario-based resilience planning",
    )

    df["planning_warning"] = np.select(
        [
            df["blind_spot_pressure_score"] - df["resilience_planning_readiness_score"] >= 0.35,
            df["blind_spot_pressure_score"] - df["resilience_planning_readiness_score"] >= 0.20,
            df["blind_spot_pressure_score"] - df["resilience_planning_readiness_score"] >= 0.05,
        ],
        [
            "Severe scenario-planning blind-spot pressure",
            "High scenario-planning blind-spot pressure",
            "Moderate scenario-planning blind-spot pressure",
        ],
        default="Lower blind-spot pressure or stronger resilience-planning readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for scenario-matrix and shock-library review."""
    columns = [
        "planning_system",
        "jurisdiction",
        "system_type",
        "scenario_matrix_quality_score",
        "shock_library_reliability_score",
        "planning_actionability_score",
        "blind_spot_pressure_score",
        "resilience_planning_readiness_score",
        "planning_readiness_gap",
        "planning_band",
        "planning_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_planning_readiness_score",
                "planning_actionability_score",
                "blind_spot_pressure_score",
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

    print("Scenario matrix and shock-library resilience planning diagnostics complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

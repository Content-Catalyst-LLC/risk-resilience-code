from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/early_warning_preparedness_panel.csv"
OUTPUT_FILE = "../outputs/early_warning_preparedness_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load an early warning and preparedness dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "jurisdiction",
        "hazard_type",
        "risk_knowledge_index",
        "forecast_skill_index",
        "lead_time_index",
        "communication_reach_index",
        "trust_strength_index",
        "preparedness_capacity_index",
        "response_capacity_index",
        "protocol_clarity_index",
        "equity_access_index",
        "household_preparedness_index",
        "community_preparedness_index",
        "institutional_preparedness_index",
        "uncertainty_burden_index",
        "access_barrier_index",
        "false_alarm_strain_index",
        "missed_alarm_risk_index",
        "institutional_fragmentation_index",
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
    Compute warning effectiveness, preparedness capacity,
    warning vulnerability, and early action readiness.
    """
    df = df.copy()

    df["warning_effectiveness_score"] = (
        0.11 * df["risk_knowledge_index"] +
        0.11 * df["forecast_skill_index"] +
        0.10 * df["lead_time_index"] +
        0.10 * df["communication_reach_index"] +
        0.09 * df["trust_strength_index"] +
        0.10 * df["preparedness_capacity_index"] +
        0.10 * df["response_capacity_index"] +
        0.08 * df["protocol_clarity_index"] +
        0.08 * df["equity_access_index"] +
        0.05 * (1 - df["uncertainty_burden_index"]) +
        0.04 * (1 - df["access_barrier_index"]) +
        0.04 * (1 - df["institutional_fragmentation_index"])
    ).clip(lower=0, upper=1)

    df["preparedness_system_score"] = (
        0.17 * df["household_preparedness_index"] +
        0.18 * df["community_preparedness_index"] +
        0.18 * df["institutional_preparedness_index"] +
        0.15 * df["preparedness_capacity_index"] +
        0.13 * df["response_capacity_index"] +
        0.11 * df["protocol_clarity_index"] +
        0.08 * df["equity_access_index"]
    ).clip(lower=0, upper=1)

    df["warning_vulnerability_score"] = (
        0.15 * df["vulnerability_exposure_index"] +
        0.14 * df["access_barrier_index"] +
        0.13 * df["institutional_fragmentation_index"] +
        0.12 * df["uncertainty_burden_index"] +
        0.11 * df["missed_alarm_risk_index"] +
        0.09 * df["false_alarm_strain_index"] +
        0.09 * (1 - df["trust_strength_index"]) +
        0.08 * (1 - df["communication_reach_index"]) +
        0.05 * (1 - df["preparedness_capacity_index"]) +
        0.04 * (1 - df["response_capacity_index"])
    ).clip(lower=0, upper=1)

    df["early_action_readiness_score"] = (
        0.38 * df["warning_effectiveness_score"] +
        0.32 * df["preparedness_system_score"] +
        0.18 * (1 - df["warning_vulnerability_score"]) +
        0.12 * df["equity_access_index"]
    ).clip(lower=0, upper=1)

    df["preparedness_gap"] = (
        df["preparedness_system_score"] -
        df["warning_vulnerability_score"]
    )

    df["readiness_band"] = np.select(
        [
            df["early_action_readiness_score"] >= 0.80,
            df["early_action_readiness_score"] >= 0.60,
            df["early_action_readiness_score"] >= 0.40,
        ],
        [
            "Strong early warning and preparedness readiness",
            "Moderate early warning and preparedness readiness",
            "Limited early warning and preparedness readiness",
        ],
        default="Weak early warning and preparedness readiness",
    )

    df["preparedness_warning"] = np.select(
        [
            df["warning_vulnerability_score"] - df["preparedness_system_score"] >= 0.35,
            df["warning_vulnerability_score"] - df["preparedness_system_score"] >= 0.20,
            df["warning_vulnerability_score"] - df["preparedness_system_score"] >= 0.05,
        ],
        [
            "Severe warning-preparedness gap",
            "High warning-preparedness gap",
            "Moderate warning-preparedness gap",
        ],
        default="Lower warning-preparedness gap or stronger readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for early warning preparedness review."""
    columns = [
        "system_name",
        "jurisdiction",
        "hazard_type",
        "warning_effectiveness_score",
        "preparedness_system_score",
        "warning_vulnerability_score",
        "early_action_readiness_score",
        "preparedness_gap",
        "readiness_band",
        "preparedness_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "early_action_readiness_score",
                "warning_effectiveness_score",
                "warning_vulnerability_score",
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

    print("Early warning and preparedness scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

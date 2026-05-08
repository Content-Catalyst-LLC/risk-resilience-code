from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_design_system_panel.csv"
OUTPUT_FILE = "../outputs/resilience_design_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """Load a system-level resilience-design dataset."""
    df = pd.read_csv(path)

    required_columns = [
        "system_name",
        "sector",
        "system_type",
        "normal_performance_index",
        "cost_efficiency_index",
        "utilization_pressure_index",
        "slack_capacity_index",
        "redundancy_capacity_index",
        "flexibility_capacity_index",
        "modularity_index",
        "dependency_visibility_index",
        "dependency_concentration_index",
        "tight_coupling_index",
        "maintenance_vulnerability_index",
        "cyber_exposure_index",
        "climate_hazard_exposure_index",
        "service_criticality_index",
        "governance_capacity_index",
        "recovery_capacity_index",
        "equity_vulnerability_index",
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
    """Compute optimization-fragility, resilience capacity, and design risk."""
    df = df.copy()

    df["optimization_fragility_score"] = (
        0.14 * df["utilization_pressure_index"] +
        0.12 * (1 - df["slack_capacity_index"]) +
        0.12 * (1 - df["redundancy_capacity_index"]) +
        0.13 * df["dependency_concentration_index"] +
        0.12 * df["tight_coupling_index"] +
        0.11 * df["maintenance_vulnerability_index"] +
        0.10 * df["cyber_exposure_index"] +
        0.10 * df["climate_hazard_exposure_index"] +
        0.06 * (1 - df["dependency_visibility_index"])
    ).clip(lower=0, upper=1)

    df["resilience_capacity_score"] = (
        0.15 * df["slack_capacity_index"] +
        0.15 * df["redundancy_capacity_index"] +
        0.14 * df["flexibility_capacity_index"] +
        0.13 * df["modularity_index"] +
        0.13 * df["dependency_visibility_index"] +
        0.14 * df["governance_capacity_index"] +
        0.10 * df["recovery_capacity_index"] +
        0.06 * (1 - df["equity_vulnerability_index"])
    ).clip(lower=0, upper=1)

    df["resilience_adjusted_design_risk"] = (
        0.38 * df["optimization_fragility_score"] +
        0.24 * (1 - df["resilience_capacity_score"]) +
        0.14 * df["service_criticality_index"] +
        0.10 * df["equity_vulnerability_index"] +
        0.08 * df["cyber_exposure_index"] +
        0.06 * df["climate_hazard_exposure_index"]
    ).clip(lower=0, upper=1)

    df["resilience_gap"] = (
        df["optimization_fragility_score"] -
        df["resilience_capacity_score"]
    )

    df["risk_band"] = np.select(
        [
            df["resilience_adjusted_design_risk"] >= 0.80,
            df["resilience_adjusted_design_risk"] >= 0.60,
            df["resilience_adjusted_design_risk"] >= 0.40,
        ],
        [
            "Extreme resilience-design risk",
            "High resilience-design risk",
            "Moderate resilience-design risk",
        ],
        default="Lower resilience-design risk",
    )

    return df


def main() -> None:
    df = load_data(INPUT_FILE)
    df = validate_indices(df)
    scored = compute_scores(df)
    scored.to_csv(OUTPUT_FILE, index=False)

    print("Resilience-design scoring complete.")
    print(scored.to_string(index=False))


if __name__ == "__main__":
    main()

from __future__ import annotations

import pandas as pd
import numpy as np

DOMAIN_INPUT_FILE = "../data/raw/polycrisis_domain_panel.csv"
INTERACTION_INPUT_FILE = "../data/raw/polycrisis_interaction_matrix.csv"
DOMAIN_OUTPUT_FILE = "../outputs/polycrisis_domain_scores.csv"
INTERACTION_OUTPUT_FILE = "../outputs/polycrisis_interaction_scores.csv"
SUMMARY_OUTPUT_FILE = "../outputs/polycrisis_resilience_scores.csv"


def load_domain_data(path: str) -> pd.DataFrame:
    """
    Load crisis-domain data.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "domain",
        "jurisdiction",
        "crisis_intensity_index",
        "systemic_vulnerability_index",
        "feedback_amplification_index",
        "threshold_proximity_index",
        "institutional_capacity_index",
        "public_legitimacy_index",
        "regenerative_capacity_index",
        "equity_integration_index",
        "data_auditability_index",
        "adaptive_learning_index",
        "maladaptation_risk_index",
    ]

    missing = [col for col in required_columns if col not in df.columns]

    if missing:
        raise ValueError(f"Missing required domain columns: {missing}")

    return df


def load_interaction_data(path: str) -> pd.DataFrame:
    """
    Load crisis-domain interaction data.

    Required columns:
      - source_domain
      - target_domain
      - coupling_weight
    """
    df = pd.read_csv(path)

    required_columns = [
        "source_domain",
        "target_domain",
        "coupling_weight",
    ]

    missing = [col for col in required_columns if col not in df.columns]

    if missing:
        raise ValueError(f"Missing required interaction columns: {missing}")

    if ((df["coupling_weight"] < 0) | (df["coupling_weight"] > 1)).any():
        raise ValueError("coupling_weight must be normalized to [0, 1].")

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


def compute_domain_scores(domain_df: pd.DataFrame) -> pd.DataFrame:
    """Compute domain-level polycrisis pressure and resilience readiness."""
    df = domain_df.copy()

    df["domain_polycrisis_pressure_score"] = (
        0.22 * df["crisis_intensity_index"]
        + 0.20 * df["systemic_vulnerability_index"]
        + 0.18 * df["feedback_amplification_index"]
        + 0.17 * df["threshold_proximity_index"]
        + 0.13 * df["maladaptation_risk_index"]
        + 0.10 * (1 - df["institutional_capacity_index"])
    ).clip(lower=0, upper=1)

    df["transformative_resilience_score"] = (
        0.18 * df["institutional_capacity_index"]
        + 0.16 * df["public_legitimacy_index"]
        + 0.16 * df["regenerative_capacity_index"]
        + 0.14 * df["equity_integration_index"]
        + 0.12 * df["data_auditability_index"]
        + 0.12 * df["adaptive_learning_index"]
        + 0.12 * (1 - df["maladaptation_risk_index"])
    ).clip(lower=0, upper=1)

    df["domain_resilience_gap"] = (
        df["transformative_resilience_score"]
        - df["domain_polycrisis_pressure_score"]
    )

    df["domain_band"] = np.select(
        [
            df["domain_polycrisis_pressure_score"] >= 0.75,
            df["domain_polycrisis_pressure_score"] >= 0.55,
            df["domain_polycrisis_pressure_score"] >= 0.35,
        ],
        [
            "Severe domain pressure",
            "High domain pressure",
            "Moderate domain pressure",
        ],
        default="Lower domain pressure",
    )

    return df


def compute_interaction_pressure(
    domain_scores: pd.DataFrame,
    interaction_df: pd.DataFrame,
) -> pd.DataFrame:
    """Compute interaction pressure between crisis domains."""
    domain_pressure = domain_scores.set_index("domain")["domain_polycrisis_pressure_score"].to_dict()

    interactions = interaction_df.copy()

    interactions["source_pressure"] = interactions["source_domain"].map(domain_pressure)
    interactions["target_pressure"] = interactions["target_domain"].map(domain_pressure)

    if interactions[["source_pressure", "target_pressure"]].isna().any().any():
        raise ValueError("Interaction matrix references domains missing from domain data.")

    interactions["interaction_pressure_score"] = (
        interactions["source_pressure"]
        * interactions["target_pressure"]
        * interactions["coupling_weight"]
    ).clip(lower=0, upper=1)

    return interactions


def build_jurisdiction_summary(
    domain_scores: pd.DataFrame,
    interactions: pd.DataFrame,
) -> pd.DataFrame:
    """Summarize polycrisis pressure and resilience readiness."""
    total_interaction_pressure = interactions["interaction_pressure_score"].sum()
    mean_interaction_pressure = interactions["interaction_pressure_score"].mean()
    max_interaction_pressure = interactions["interaction_pressure_score"].max()

    summary = domain_scores.groupby("jurisdiction").agg(
        avg_domain_polycrisis_pressure=("domain_polycrisis_pressure_score", "mean"),
        max_domain_polycrisis_pressure=("domain_polycrisis_pressure_score", "max"),
        avg_transformative_resilience=("transformative_resilience_score", "mean"),
        min_transformative_resilience=("transformative_resilience_score", "min"),
        avg_domain_resilience_gap=("domain_resilience_gap", "mean"),
        avg_institutional_capacity=("institutional_capacity_index", "mean"),
        avg_public_legitimacy=("public_legitimacy_index", "mean"),
        avg_regenerative_capacity=("regenerative_capacity_index", "mean"),
        avg_equity_integration=("equity_integration_index", "mean"),
        avg_data_auditability=("data_auditability_index", "mean"),
        avg_maladaptation_risk=("maladaptation_risk_index", "mean"),
        domains=("domain", "count"),
    ).reset_index()

    summary["total_interaction_pressure"] = total_interaction_pressure
    summary["mean_interaction_pressure"] = mean_interaction_pressure
    summary["max_interaction_pressure"] = max_interaction_pressure

    summary["overall_polycrisis_pressure"] = (
        0.50 * summary["avg_domain_polycrisis_pressure"]
        + 0.25 * summary["max_domain_polycrisis_pressure"]
        + 0.15 * summary["mean_interaction_pressure"]
        + 0.10 * summary["max_interaction_pressure"]
    ).clip(lower=0, upper=1)

    summary["polycrisis_resilience_readiness"] = (
        0.40 * summary["avg_transformative_resilience"]
        + 0.20 * summary["min_transformative_resilience"]
        + 0.15 * summary["avg_public_legitimacy"]
        + 0.10 * summary["avg_regenerative_capacity"]
        + 0.10 * summary["avg_data_auditability"]
        + 0.05 * summary["avg_equity_integration"]
    ).clip(lower=0, upper=1)

    summary["polycrisis_readiness_gap"] = (
        summary["polycrisis_resilience_readiness"]
        - summary["overall_polycrisis_pressure"]
    )

    summary["polycrisis_band"] = np.select(
        [
            summary["overall_polycrisis_pressure"] >= 0.75,
            summary["overall_polycrisis_pressure"] >= 0.55,
            summary["overall_polycrisis_pressure"] >= 0.35,
        ],
        [
            "Severe polycrisis pressure",
            "High polycrisis pressure",
            "Moderate polycrisis pressure",
        ],
        default="Lower polycrisis pressure",
    )

    summary["resilience_warning"] = np.select(
        [
            summary["overall_polycrisis_pressure"] - summary["polycrisis_resilience_readiness"] >= 0.35,
            summary["overall_polycrisis_pressure"] - summary["polycrisis_resilience_readiness"] >= 0.20,
            summary["overall_polycrisis_pressure"] - summary["polycrisis_resilience_readiness"] >= 0.05,
        ],
        [
            "Severe polycrisis readiness gap",
            "High polycrisis readiness gap",
            "Moderate polycrisis readiness gap",
        ],
        default="Lower readiness gap or stronger transformative resilience",
    )

    return summary.sort_values("overall_polycrisis_pressure", ascending=False)


def main() -> None:
    domain_df = load_domain_data(DOMAIN_INPUT_FILE)
    interaction_df = load_interaction_data(INTERACTION_INPUT_FILE)

    domain_df = validate_indices(domain_df)
    domain_scores = compute_domain_scores(domain_df)
    interactions = compute_interaction_pressure(domain_scores, interaction_df)
    summary = build_jurisdiction_summary(domain_scores, interactions)

    domain_scores.to_csv(DOMAIN_OUTPUT_FILE, index=False)
    interactions.to_csv(INTERACTION_OUTPUT_FILE, index=False)
    summary.to_csv(SUMMARY_OUTPUT_FILE, index=False)

    print("Polycrisis domain scores:")
    print(domain_scores.to_string(index=False))

    print("\nHighest interaction pressures:")
    print(
        interactions.sort_values("interaction_pressure_score", ascending=False)
        .head(10)
        .to_string(index=False)
    )

    print("\nPolycrisis resilience summary:")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

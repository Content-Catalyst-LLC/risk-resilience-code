from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/resilience_data_provenance_panel.csv"
OUTPUT_FILE = "../outputs/resilience_data_provenance_audit_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a resilience data provenance and auditability dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "dataset_name",
        "jurisdiction",
        "data_domain",
        "provenance_completeness_index",
        "metadata_quality_index",
        "lineage_clarity_index",
        "audit_evidence_index",
        "reproducibility_index",
        "data_quality_index",
        "version_control_index",
        "chain_of_custody_index",
        "equity_coverage_index",
        "community_validation_index",
        "privacy_safeguard_index",
        "security_control_index",
        "responsible_owner_index",
        "missingness_gap_index",
        "opacity_risk_index",
        "undocumented_transformation_index",
        "stale_data_risk_index",
        "sensitive_data_exposure_risk_index",
        "audit_gap_index",
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
    Compute provenance strength, auditability strength,
    governance protection, data-risk pressure, and data-trust score.
    """
    df = df.copy()

    df["provenance_strength_score"] = (
        0.22 * df["provenance_completeness_index"] +
        0.18 * df["metadata_quality_index"] +
        0.18 * df["lineage_clarity_index"] +
        0.14 * df["version_control_index"] +
        0.12 * df["responsible_owner_index"] +
        0.10 * df["data_quality_index"] +
        0.06 * df["chain_of_custody_index"]
    ).clip(lower=0, upper=1)

    df["auditability_strength_score"] = (
        0.24 * df["audit_evidence_index"] +
        0.18 * df["reproducibility_index"] +
        0.16 * df["version_control_index"] +
        0.14 * df["chain_of_custody_index"] +
        0.12 * df["responsible_owner_index"] +
        0.10 * df["metadata_quality_index"] +
        0.06 * df["lineage_clarity_index"]
    ).clip(lower=0, upper=1)

    df["ethical_governance_score"] = (
        0.22 * df["privacy_safeguard_index"] +
        0.20 * df["security_control_index"] +
        0.18 * df["equity_coverage_index"] +
        0.16 * df["community_validation_index"] +
        0.14 * df["responsible_owner_index"] +
        0.10 * df["data_quality_index"]
    ).clip(lower=0, upper=1)

    df["data_risk_pressure_score"] = (
        0.22 * df["missingness_gap_index"] +
        0.20 * df["opacity_risk_index"] +
        0.18 * df["undocumented_transformation_index"] +
        0.15 * df["stale_data_risk_index"] +
        0.13 * df["sensitive_data_exposure_risk_index"] +
        0.12 * df["audit_gap_index"]
    ).clip(lower=0, upper=1)

    df["resilience_data_trust_score"] = (
        0.30 * df["provenance_strength_score"] +
        0.26 * df["auditability_strength_score"] +
        0.20 * df["ethical_governance_score"] +
        0.14 * df["data_quality_index"] +
        0.10 * (1 - df["data_risk_pressure_score"])
    ).clip(lower=0, upper=1)

    df["audit_readiness_gap"] = (
        df["resilience_data_trust_score"] -
        df["data_risk_pressure_score"]
    )

    df["data_trust_band"] = np.select(
        [
            df["resilience_data_trust_score"] >= 0.80,
            df["resilience_data_trust_score"] >= 0.60,
            df["resilience_data_trust_score"] >= 0.40,
        ],
        [
            "Strong resilience data trust",
            "Moderate resilience data trust",
            "Limited resilience data trust",
        ],
        default="Weak resilience data trust",
    )

    df["audit_warning"] = np.select(
        [
            df["data_risk_pressure_score"] - df["resilience_data_trust_score"] >= 0.35,
            df["data_risk_pressure_score"] - df["resilience_data_trust_score"] >= 0.20,
            df["data_risk_pressure_score"] - df["resilience_data_trust_score"] >= 0.05,
        ],
        [
            "Severe provenance and auditability gap",
            "High provenance and auditability gap",
            "Moderate provenance and auditability gap",
        ],
        default="Lower data-risk pressure or stronger audit readiness",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for resilience data governance review."""
    columns = [
        "dataset_name",
        "jurisdiction",
        "data_domain",
        "provenance_strength_score",
        "auditability_strength_score",
        "ethical_governance_score",
        "data_risk_pressure_score",
        "resilience_data_trust_score",
        "audit_readiness_gap",
        "data_trust_band",
        "audit_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_data_trust_score",
                "auditability_strength_score",
                "data_risk_pressure_score",
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

    print("Resilience data provenance and auditability scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

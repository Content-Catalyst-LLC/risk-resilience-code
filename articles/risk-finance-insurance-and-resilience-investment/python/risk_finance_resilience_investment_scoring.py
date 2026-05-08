from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/risk_finance_resilience_investment_panel.csv"
OUTPUT_FILE = "../outputs/risk_finance_resilience_investment_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a risk finance, insurance, and resilience investment dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "jurisdiction_or_portfolio",
        "risk_domain",
        "sector",
        "risk_visibility_index",
        "insurance_coverage_index",
        "prearranged_finance_index",
        "fiscal_capacity_index",
        "resilience_investment_index",
        "mitigation_incentive_index",
        "equity_protection_index",
        "insurance_affordability_index",
        "public_risk_pool_capacity_index",
        "contingent_credit_capacity_index",
        "catastrophe_bond_capacity_index",
        "social_protection_capacity_index",
        "disclosure_quality_index",
        "protection_gap_index",
        "debt_stress_index",
        "hidden_exposure_index",
        "systemic_transmission_risk_index",
        "maladaptation_risk_index",
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
    Compute resilience finance capacity, protection gap pressure,
    risk visibility/governance, and resilience-adjusted financial risk.
    """
    df = df.copy()

    df["resilience_finance_capacity_score"] = (
        0.11 * df["risk_visibility_index"] +
        0.10 * df["insurance_coverage_index"] +
        0.10 * df["prearranged_finance_index"] +
        0.10 * df["fiscal_capacity_index"] +
        0.11 * df["resilience_investment_index"] +
        0.09 * df["mitigation_incentive_index"] +
        0.09 * df["equity_protection_index"] +
        0.08 * df["insurance_affordability_index"] +
        0.07 * df["public_risk_pool_capacity_index"] +
        0.06 * df["contingent_credit_capacity_index"] +
        0.05 * df["catastrophe_bond_capacity_index"] +
        0.04 * df["social_protection_capacity_index"]
    ).clip(lower=0, upper=1)

    df["protection_gap_pressure_score"] = (
        0.18 * df["protection_gap_index"] +
        0.15 * df["debt_stress_index"] +
        0.14 * df["hidden_exposure_index"] +
        0.13 * df["systemic_transmission_risk_index"] +
        0.12 * df["maladaptation_risk_index"] +
        0.10 * (1 - df["insurance_affordability_index"]) +
        0.08 * (1 - df["insurance_coverage_index"]) +
        0.06 * (1 - df["prearranged_finance_index"]) +
        0.04 * (1 - df["equity_protection_index"])
    ).clip(lower=0, upper=1)

    df["risk_visibility_and_governance_score"] = (
        0.24 * df["risk_visibility_index"] +
        0.22 * df["disclosure_quality_index"] +
        0.18 * df["mitigation_incentive_index"] +
        0.16 * df["resilience_investment_index"] +
        0.12 * df["equity_protection_index"] +
        0.08 * (1 - df["hidden_exposure_index"])
    ).clip(lower=0, upper=1)

    df["resilience_adjusted_financial_risk"] = (
        0.34 * df["protection_gap_pressure_score"] +
        0.24 * (1 - df["resilience_finance_capacity_score"]) +
        0.16 * (1 - df["risk_visibility_and_governance_score"]) +
        0.14 * df["systemic_transmission_risk_index"] +
        0.12 * df["debt_stress_index"]
    ).clip(lower=0, upper=1)

    df["finance_resilience_gap"] = (
        df["resilience_finance_capacity_score"] -
        df["protection_gap_pressure_score"]
    )

    df["risk_band"] = np.select(
        [
            df["resilience_adjusted_financial_risk"] >= 0.80,
            df["resilience_adjusted_financial_risk"] >= 0.60,
            df["resilience_adjusted_financial_risk"] >= 0.40,
        ],
        [
            "Extreme resilience finance risk",
            "High resilience finance risk",
            "Moderate resilience finance risk",
        ],
        default="Lower resilience finance risk",
    )

    df["finance_warning"] = np.select(
        [
            df["protection_gap_pressure_score"] - df["resilience_finance_capacity_score"] >= 0.35,
            df["protection_gap_pressure_score"] - df["resilience_finance_capacity_score"] >= 0.20,
            df["protection_gap_pressure_score"] - df["resilience_finance_capacity_score"] >= 0.05,
        ],
        [
            "Severe protection-gap finance gap",
            "High protection-gap finance gap",
            "Moderate protection-gap finance gap",
        ],
        default="Lower protection-gap pressure or stronger resilience finance capacity",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for risk finance and resilience investment review."""
    columns = [
        "jurisdiction_or_portfolio",
        "risk_domain",
        "sector",
        "resilience_finance_capacity_score",
        "protection_gap_pressure_score",
        "risk_visibility_and_governance_score",
        "resilience_adjusted_financial_risk",
        "finance_resilience_gap",
        "risk_band",
        "finance_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "resilience_adjusted_financial_risk",
                "protection_gap_pressure_score",
                "resilience_finance_capacity_score",
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

    print("Risk finance and resilience investment scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

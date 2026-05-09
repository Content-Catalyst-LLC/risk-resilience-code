from __future__ import annotations

import pandas as pd
import numpy as np

INPUT_FILE = "../data/raw/biodiversity_ecological_resilience_panel.csv"
OUTPUT_FILE = "../outputs/biodiversity_ecological_resilience_scores.csv"


def load_data(path: str) -> pd.DataFrame:
    """
    Load a biodiversity and ecological resilience dataset.

    All *_index columns should be normalized to [0, 1].
    Higher values should mean more of the named property.
    """
    df = pd.read_csv(path)

    required_columns = [
        "ecosystem_name",
        "jurisdiction",
        "ecosystem_type",
        "genetic_diversity_index",
        "species_diversity_index",
        "functional_diversity_index",
        "habitat_connectivity_index",
        "ecosystem_integrity_index",
        "adaptive_capacity_index",
        "governance_quality_index",
        "community_stewardship_index",
        "fragmentation_pressure_index",
        "pollution_pressure_index",
        "invasive_pressure_index",
        "extraction_pressure_index",
        "climate_stress_index",
        "monitoring_gap_index",
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
    Compute biodiversity-supported resilience, ecological pressure,
    and ecological resilience gap.
    """
    df = df.copy()

    df["biodiversity_resilience_score"] = (
        0.15 * df["genetic_diversity_index"] +
        0.16 * df["species_diversity_index"] +
        0.17 * df["functional_diversity_index"] +
        0.15 * df["habitat_connectivity_index"] +
        0.15 * df["ecosystem_integrity_index"] +
        0.10 * df["adaptive_capacity_index"] +
        0.07 * df["governance_quality_index"] +
        0.05 * df["community_stewardship_index"]
    ).clip(lower=0, upper=1)

    df["ecological_pressure_score"] = (
        0.18 * df["fragmentation_pressure_index"] +
        0.16 * df["pollution_pressure_index"] +
        0.16 * df["invasive_pressure_index"] +
        0.18 * df["extraction_pressure_index"] +
        0.20 * df["climate_stress_index"] +
        0.12 * df["monitoring_gap_index"]
    ).clip(lower=0, upper=1)

    df["ecological_resilience_gap"] = (
        df["biodiversity_resilience_score"] -
        df["ecological_pressure_score"]
    )

    df["resilience_band"] = np.select(
        [
            df["biodiversity_resilience_score"] >= 0.80,
            df["biodiversity_resilience_score"] >= 0.60,
            df["biodiversity_resilience_score"] >= 0.40,
        ],
        [
            "Strong biodiversity-supported resilience",
            "Moderate biodiversity-supported resilience",
            "Limited biodiversity-supported resilience",
        ],
        default="Weak biodiversity-supported resilience",
    )

    df["pressure_warning"] = np.select(
        [
            df["ecological_pressure_score"] - df["biodiversity_resilience_score"] >= 0.35,
            df["ecological_pressure_score"] - df["biodiversity_resilience_score"] >= 0.20,
            df["ecological_pressure_score"] - df["biodiversity_resilience_score"] >= 0.05,
        ],
        [
            "Severe ecological pressure exceeds biodiversity resilience",
            "High ecological pressure exceeds biodiversity resilience",
            "Moderate ecological pressure exceeds biodiversity resilience",
        ],
        default="Lower pressure or stronger biodiversity resilience",
    )

    return df


def build_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Return a ranked summary table for ecological resilience review."""
    columns = [
        "ecosystem_name",
        "jurisdiction",
        "ecosystem_type",
        "biodiversity_resilience_score",
        "ecological_pressure_score",
        "ecological_resilience_gap",
        "resilience_band",
        "pressure_warning",
    ]

    return (
        df[columns]
        .sort_values(
            by=[
                "ecological_resilience_gap",
                "biodiversity_resilience_score",
                "ecological_pressure_score",
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

    print("Biodiversity and ecological resilience scoring complete.")
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()

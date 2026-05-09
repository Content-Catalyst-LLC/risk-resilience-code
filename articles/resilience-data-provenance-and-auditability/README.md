# Resilience Data, Provenance, and Auditability

This article directory supports the Risk & Resilience article:

**Resilience Data, Provenance, and Auditability**

The workflows model how provenance completeness, metadata quality, lineage clarity, audit evidence, reproducibility, data quality, version control, chain of custody, equity coverage, community validation, privacy safeguards, security controls, responsible ownership, missingness gaps, opacity, undocumented transformations, stale data, sensitive-data exposure, and audit gaps shape resilience-data trust.

## Analytical Focus

The article examines:

- Resilience data governance
- Data provenance
- Auditability
- Data lineage
- Metadata quality
- Reproducibility
- Version control
- Chain of custody
- Dashboard credibility
- Indicator governance
- Data-quality review
- Community data and lived evidence
- Marginalized visibility
- Privacy safeguards
- Security controls
- Missingness gaps
- Undocumented transformations
- Stale data risk
- Audit readiness

## Suggested Input Dataset

Expected file:

```text
resilience_data_provenance_panel.csv
```

Each `*_index` field should be normalized from 0 to 1.

Higher values should mean more of the named property. For example:

- `provenance_completeness_index`: higher = stronger provenance records
- `audit_evidence_index`: higher = stronger inspectable evidence
- `missingness_gap_index`: higher = more missing or undercovered evidence
- `opacity_risk_index`: higher = less explainable or less inspectable data process

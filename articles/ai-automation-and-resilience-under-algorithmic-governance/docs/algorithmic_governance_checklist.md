# Algorithmic Resilience Governance Checklist

Use this checklist when reviewing AI systems, automated workflows, decision-support systems, model deployments, vendor tools, or algorithmic dashboards used in resilience-related contexts.

## Purpose and Scope

- What decision or workflow does the system affect?
- Is AI necessary for this purpose?
- What happens if the system is wrong?
- What rights, services, safety issues, or public interests are affected?
- What should not be automated?

## Data and Provenance

- What datasets are used?
- Are sources, transformations, versions, and assumptions documented?
- Who is missing from the data?
- Are proxy variables used?
- Are data-quality limitations disclosed?

## Model Governance

- What model version is deployed?
- How was it trained, validated, and tested?
- What performance differences appear across groups?
- What thresholds are used?
- What uncertainty is disclosed?
- What failure modes are known?

## Human Oversight and Contestability

- Who can override the model?
- Are overrides logged and reviewed?
- Can affected people appeal decisions?
- Are explanations accessible?
- Are staff trained to challenge the system?

## Security and Resilience

- What are the cyber risks?
- What APIs, vendors, cloud systems, and integrations are involved?
- Is there fallback capacity?
- Can the institution operate in degraded mode?
- Has adversarial testing been performed?

## Monitoring and Accountability

- Is drift monitored?
- Are incidents logged and reviewed?
- Are disparities tracked over time?
- Are vendors auditable?
- Are public reports available where appropriate?
- Is there a retirement or suspension process?

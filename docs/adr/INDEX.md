# ADR Index

All architecture decisions, chronologically.

| ID | Title | Status | Date | Deciders |
|----|-------|--------|------|----------|
| [0001](./0001-record-architecture-decisions.md) | Record architecture decisions in ADRs | Accepted | 2026-08-02 | A-LEAD |
| [0002](./0002-opentofu-vs-terraform.md) | Use OpenTofu instead of Terraform | Accepted | 2026-08-02 | A-LEAD, D-OPS |
| [0011](./0011-python-fastapi-over-java-spring.md) | Python + FastAPI over Java + Spring | Accepted | 2026-08-02 | A-LEAD, B-DEV |

## Reserved number ranges

To avoid collisions, ADR numbers are grouped thematically:

| Range | Theme |
|-------|-------|
| 0001–0009 | Governance and meta-decisions |
| 0010–0019 | Language and application frameworks |
| 0020–0029 | Data and persistence |
| 0030–0039 | Infrastructure and compute |
| 0040–0049 | Observability |
| 0050–0059 | Security |
| 0060+ | Sprint-specific decisions |

## Upcoming ADRs (planned)

These will be written when the corresponding sprint reaches the decision point:

- `ADR-0003` — Multi-account AWS strategy
- `ADR-0004` — EKS Auto Mode vs manual Karpenter
- `ADR-0005` — ArgoCD as GitOps engine
- `ADR-0006` — Observability stack (OTel + Grafana LGTM)
- `ADR-0007` — AI-assisted development workflow
- `ADR-0008` — LLM abstraction for AI-Ops
- `ADR-0009` — Transactional Outbox pattern
- `ADR-0010` — Cloud ↔ local equivalence strategy
- `ADR-0012` — Trunk-based development

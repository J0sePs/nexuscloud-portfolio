# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records for the NexusCloud project,
following the [MADR 4.0](https://adr.github.io/madr/) format.

## What is an ADR?

An ADR is a document that captures an **important architectural decision**,
including its **context**, the **considered options**, the **decision itself**,
and its **consequences**. Once accepted, an ADR is immutable — if the decision
changes, a new ADR is written that supersedes the old one.

## When to write an ADR

Write an ADR when a decision:
- Affects multiple services or the overall system topology
- Involves choosing between multiple viable alternatives
- Has non-trivial long-term consequences (cost, performance, security, operability)
- Establishes a convention that others must follow
- Is expensive or slow to reverse

Do **not** write an ADR for:
- Trivial choices (variable naming, code formatting)
- Purely local decisions within a single function/module
- Decisions already covered by an existing ADR

## ADR lifecycle statuses

- `Proposed` — Under discussion, not yet accepted
- `Accepted` — Adopted and in effect
- `Deprecated` — No longer recommended for new work, but existing implementations remain
- `Superseded by ADR-NNNN` — Replaced by a newer decision

## Naming convention

`NNNN-short-slug.md` where `NNNN` is a zero-padded incremental number.

Example: `0002-opentofu-vs-terraform.md`

## Index

See [INDEX.md](./INDEX.md) for the full catalog of ADRs.

## References

- [MADR project](https://adr.github.io/madr/)
- [Documenting Architecture Decisions — Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ThoughtWorks Tech Radar: Lightweight ADRs](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records)

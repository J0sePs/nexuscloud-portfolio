# ADR-0001: Record architecture decisions in ADRs

- **Status:** Accepted
- **Date:** 2026-08-07
- **Deciders:** A-LEAD
- **Tags:** governance, documentation, culture

## Context and Problem Statement

The NexusCloud portfolio project will make many architectural decisions
over its lifetime (choice of IaC tooling, language, orchestration platform,
observability stack, etc.). Without a systematic way to record these
decisions:

- The rationale gets lost as team members join and leave
- Old decisions get revisited unnecessarily because nobody remembers why
  they were made
- "Institutional memory" lives in individuals rather than the repository
- Onboarding a new engineer takes weeks of tribal-knowledge transfer
- When something breaks, it's hard to distinguish "the design was flawed"
  from "the constraints have changed"

## Decision Drivers

- Decisions must be discoverable by anyone who reads the repository
- The format must be lightweight enough that engineers actually write them
- The format must be structured enough to make comparisons across
  decisions (patterns, trends, anti-patterns) possible
- The format must be version-controlled alongside the code it describes
- The format must be readable in plain-text tools (`cat`, `grep`,
  `git diff`) as well as rendered UIs (GitHub, Obsidian)

## Considered Options

1. **No formal record** — Rely on commit messages, code comments, and
   Slack conversations
2. **Confluence pages** — External wiki with rich formatting
3. **Michael Nygard ADR format** — Original 5-section markdown template
4. **MADR 4.0** — Extended markdown template with explicit decision drivers
   and considered options
5. **Y-statements** — Compact single-sentence decision format

## Decision Outcome

Chosen option: **MADR 4.0**, because it satisfies all drivers and is the
most widely adopted format in modern engineering organizations. ADRs will
live in `docs/adr/` in this repository. See [`docs/adr/README.md`](./README.md)
for the framework details and [`0000-template.md`](./0000-template.md) for
the exact structure.

### Consequences

**Positive:**
- New engineers can understand "why" decisions were made by reading ADRs
- Discussions during code review can reference specific ADRs (e.g.,
  "see ADR-0002 for the OpenTofu rationale")
- Superseded decisions are visible via git history, providing an audit trail
- Interview evidence: ADRs are prized artifacts by senior hiring managers

**Negative:**
- Writing an ADR adds ~30–60 minutes to significant architectural changes
- Requires discipline to keep the practice alive across all contributors
- Risk of ADR-bloat if applied to trivial decisions (mitigated by the
  "When to write an ADR" section in the README)

**Neutral:**
- ADRs must be updated (via superseding) when circumstances change; they
  are not living documents

## Pros and Cons of the Options

### Option 1 — No formal record
- ✅ Pro: Zero overhead
- ❌ Con: Impossible to reconstruct rationale after 6 months
- ❌ Con: Doesn't scale beyond ~3 people
- ❌ Con: No artifact to show in interviews

### Option 2 — Confluence pages
- ✅ Pro: Rich formatting, familiar to many teams
- ❌ Con: External to code repository — decisions drift out of sync
- ❌ Con: Requires Confluence license
- ❌ Con: Not usable in plain-text tools (`grep`, `git diff`)
- ❌ Con: Poor experience for local editing in Obsidian/VS Code

### Option 3 — Michael Nygard ADR format
- ✅ Pro: Minimal, easy to adopt
- ✅ Pro: Historically important — well known
- ❌ Con: No explicit "Considered Options" section — encourages
  confirmation bias

### Option 4 — MADR 4.0
- ✅ Pro: Forces analysis of alternatives via "Considered Options"
- ✅ Pro: Structured enough for cross-ADR analysis
- ✅ Pro: Tool support (adr-tools, Backstage plugin, IDE extensions)
- ✅ Pro: Widely adopted in senior engineering job descriptions
- ❌ Con: Slightly more verbose than Nygard original

### Option 5 — Y-statements
- ✅ Pro: Ultra-compact (one sentence)
- ❌ Con: Insufficient context for non-trivial decisions
- ❌ Con: No structured comparison of alternatives

## More Information

- MADR project: https://adr.github.io/madr/
- Michael Nygard's original blog post:
  https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- ThoughtWorks Tech Radar (Lightweight ADRs — Adopt since 2019):
  https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records

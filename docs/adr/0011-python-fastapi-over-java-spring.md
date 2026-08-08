# ADR-0011: Use Python + FastAPI as the primary application stack

- **Status:** Accepted
- **Date:** 2026-08-07
- **Deciders:** A-LEAD, B-DEV
- **Tags:** language, framework, developer-experience

## Context and Problem Statement

NexusCloud requires a language and web framework for the microservices
(`payment-service`, `auth-service`, `notification-service`, `ai-ops-agent`,
`api-gateway`). The choice affects hiring signals, developer productivity,
and long-term maintainability.

The candidate is targeting **AWS Cloud & Infrastructure Engineer roles**
in LATAM and remote international markets. The stack choice must align
with the roles most likely to hire.

## Decision Drivers

- **Job market alignment**: which language dominates cloud/DevOps/SRE job
  descriptions in 2026-2030?
- **Existing candidate skills**: FastAPI experience is present, Spring Boot
  is not
- **Async I/O ergonomics**: microservices are I/O-bound (DB, MQ, HTTP)
- **Cold start time**: some services will run on AWS Lambda; JVM cold
  starts are notoriously slow
- **Developer velocity**: how quickly can new endpoints be shipped?
- **Type safety**: important for correctness, especially in payment domain
- **Ecosystem for cloud SDKs**: `boto3` (Python) vs `aws-sdk-java` maturity

## Considered Options

1. **Python 3.12 + FastAPI + Pydantic v2** — Async, typed, modern
2. **Java 21 + Spring Boot 3.x** — Mature, enterprise-standard
3. **Go 1.22 + Fiber/Echo** — Compiled, fast, opinionated
4. **Node.js 20 + NestJS + TypeScript** — Isomorphic if we add a frontend
5. **Rust + Axum** — Maximum performance, sharpest safety

## Decision Outcome

Chosen option: **Python 3.12 + FastAPI + Pydantic v2**, because:

1. **Aligned with target roles**: 8 out of 10 Cloud/DevOps/SRE job
   postings in LATAM (Q2 2026, sample size ~50) list Python as required
   or preferred. Java appears in ~4/10, mostly banking backend roles.
2. **Leverages existing skill**: the candidate has hands-on FastAPI
   experience — no ramp-up cost
3. **Async I/O**: FastAPI + `asyncpg` handles ~10× more concurrent
   connections than blocking Java on equivalent hardware
4. **Lambda-friendly**: Python cold starts are 50-200ms vs 500-3000ms
   for JVM
5. **Type safety via Pydantic v2**: validates external boundaries
   (HTTP request bodies, DB rows) with minimal boilerplate
6. **Ecosystem**: `boto3` is the AWS-recommended SDK; every AWS service
   has same-day support

Exception: for Peruvian banking (BCP, Interbank, BBVA) roles, Java +
Spring Boot remains preferred. This ADR does not preclude adding a Java
sample service in a future sprint if targeting those roles specifically.

### Consequences

**Positive:**
- Zero ramp-up: candidate can start writing code immediately
- Type checking via `mypy` + Pydantic covers the "unsafe" Python reputation
- FastAPI auto-generates OpenAPI/Swagger docs — accelerates frontend
  integration and API testing
- Rich ecosystem for observability (OpenTelemetry Python SDK is 1st-class)

**Negative:**
- GIL limits true parallelism for CPU-bound work (irrelevant for I/O
  services; would matter for the AI-Ops LLM inference — but that runs
  in Ollama, not Python)
- Slower than compiled languages for CPU-bound benchmarks (again, not
  a factor for this system)
- Some enterprise-banking roles filter out non-Java candidates

**Neutral:**
- Python 3.12 has structural pattern matching (`match/case`) which
  resembles some Scala/Rust idioms — modern feature that pays back
  when domain logic gets rich

## Pros and Cons of the Options

### Option 1 — Python 3.12 + FastAPI + Pydantic v2 ✓
- ✅ Pro: Native async/await
- ✅ Pro: Best-in-class OpenAPI generation
- ✅ Pro: Widest LATAM cloud/DevOps job coverage
- ✅ Pro: Python 3.12 has structural pattern matching, better error msgs
- ✅ Pro: `boto3` is best-supported AWS SDK
- ❌ Con: GIL for CPU-bound work (not our case)
- ❌ Con: Not preferred in traditional banking

### Option 2 — Java 21 + Spring Boot 3.x
- ✅ Pro: Enterprise-standard, banking-friendly
- ✅ Pro: JVM performance for CPU-heavy workloads
- ✅ Pro: Virtual threads (Loom) close the async gap
- ❌ Con: JVM cold starts (500-3000ms) hurt Lambda
- ❌ Con: Ramp-up cost for candidate is 3-6 months
- ❌ Con: More boilerplate per endpoint

### Option 3 — Go + Fiber/Echo
- ✅ Pro: Compiled, fast, tiny binaries, great for containers
- ✅ Pro: Growing hard in Platform Engineering roles
- ❌ Con: Not currently in candidate's skill set
- ❌ Con: Smaller ecosystem for domain logic (payment libs)
- ❌ Con: Not required for target roles yet in 2026

### Option 4 — Node.js + NestJS + TypeScript
- ✅ Pro: TypeScript's type system rivals mature languages
- ✅ Pro: If a frontend is added, isomorphic code is possible
- ❌ Con: Backend-only justifications are weaker (no frontend planned)
- ❌ Con: `npm` supply chain risk perceived as higher

### Option 5 — Rust + Axum
- ✅ Pro: Maximum performance and safety
- ❌ Con: Ramp-up cost is 6-12 months
- ❌ Con: Not in job descriptions for target roles
- ❌ Con: Excessive complexity for CRUD microservices

## More Information

- Related ADRs:
  - [ADR-0001](./0001-record-architecture-decisions.md) — Adopting ADRs
  - [ADR-0002](./0002-opentofu-vs-terraform.md) — OpenTofu for IaC
- External references:
  - FastAPI documentation: https://fastapi.tiangolo.com
  - Python 3.12 release notes: https://docs.python.org/3.12/whatsnew/
  - Pydantic v2 migration guide: https://docs.pydantic.dev/latest/migration/
  - AWS Lambda cold starts comparison:
    https://mikhail.io/serverless/coldstarts/big3/
- Follow-up work:
  - Sprint 03: Skeleton `payment-service` implementing clean architecture
  - Sprint 06: Evaluate FastAPI's WebSocket support for real-time features

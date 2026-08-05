# 02 · Technical Skills Matrix (2026 → 2030)

> **Objetivo:** definir con precisión qué habilidades técnicas vas a demostrar en el proyecto, con la terminología en inglés que usan las job descriptions y los reclutadores internacionales. Este documento es tu **glosario y checklist técnico**.

---

## 📋 1. Skills Matrix by Domain

### 1.1 Infrastructure as Code (IaC)

| Skill | Proficiency needed | Evidence in project |
|---|---|---|
| **OpenTofu / Terraform** (HCL syntax, modules, state, backends) | Working | Modules for networking, EKS, data-layer, security |
| **State management** (remote state, locking, workspaces) | Working | S3 + DynamoDB lock (LocalStack in dev) |
| **Provider configuration** (multi-region, multi-account aliasing) | Working | Aliased providers for primary/DR regions |
| **Testing IaC** (`tofu validate`, `tofu plan`, Terratest basics) | Familiarity | Plan-in-PR workflow, tfsec/Checkov integration |
| **CloudFormation basics** | Familiarity | Read/understand, not primary IaC |
| **CDK basics (TypeScript/Python)** | Awareness | Mention in ADR why not chosen |

### 1.2 AWS Services (Core)

| Service | Proficiency | Use case in project |
|---|---|---|
| **EC2** (instance types, AMIs, EBS, security groups) | Working | Bastion host, self-managed nodes if needed |
| **VPC** (subnets, route tables, NAT, IGW, endpoints, TGW) | Working | Full network design |
| **IAM** (users, roles, policies, trust relationships, IRSA) | Working ⭐ | Least-privilege everywhere |
| **S3** (buckets, versioning, encryption, lifecycle, CRR) | Working | Payment invoices bucket |
| **RDS / Aurora** (Postgres, Multi-AZ, read replicas, Global DB) | Working | Payment DB |
| **DynamoDB** (partition keys, GSIs, DAX awareness) | Familiarity | Sessions/tokens store |
| **Lambda** (Python, layers, cold starts, VPC config) | Working | Auth service, event processors |
| **SQS / SNS** (queues, DLQ, FIFO vs standard) | Working | Async payment processing |
| **EventBridge** (rules, targets, schemas) | Familiarity | Domain events routing |
| **API Gateway** (REST, WebSocket, throttling, auth) | Working | Ingress for auth flows |
| **CloudFront + WAF + ACM** | Familiarity | Edge documented, sim nginx-ingress local |
| **Route 53** (hosted zones, routing policies, health checks) | Working | Failover routing |
| **KMS** (customer-managed keys, envelope encryption) | Familiarity | S3, Secrets Manager, EBS |
| **Secrets Manager** (rotation, integration) | Working | DB credentials, JWT signing keys |
| **Cognito** (user pools, identity pools, JWT) | Familiarity | Auth (local: Keycloak) |
| **CloudWatch** (Logs, Metrics, Alarms) | Working | Replaced local by Grafana stack |
| **GuardDuty / Security Hub / Config** | Awareness | Documented, not deployed local |
| **Organizations / Control Tower / IAM Identity Center** | Familiarity | Multi-account strategy documented |

**Proficiency levels:**
- **Awareness** — sé qué es y cuándo aplica
- **Familiarity** — lo puedo leer y hacer troubleshooting básico
- **Working** — lo uso día a día, puedo diseñar con él ⭐ = mandatory
- **Expert** — lo domino profundamente (típicamente año 3+)

### 1.3 Containers & Orchestration

| Skill | Proficiency | Evidence |
|---|---|---|
| **Docker** (multi-stage builds, distroless, non-root, healthchecks) | Working ⭐ | All 5 microservices |
| **Docker Compose** (networks, volumes, dependencies, healthchecks) | Working ⭐ | Local dev stack |
| **Kubernetes core** (Pods, Deployments, Services, Ingress, ConfigMaps, Secrets) | Working ⭐ | All apps run on kind/EKS |
| **Kubernetes advanced** (HPA, PDB, NetworkPolicy, RBAC, PSA/PSS) | Working | Documented in Helm charts |
| **Helm** (charts, values, dependencies, hooks) | Working | Custom charts per service |
| **kind** (local clusters) | Working | Primary local K8s |
| **EKS Auto Mode** | Familiarity | Documented target for cloud |
| **Karpenter** (v1 provisioners, node classes) | Familiarity | Explained in ADR |
| **Istio / Linkerd** service mesh | Awareness | Mentioned as future work |
| **Container security** (image scanning, admission controllers) | Working | Trivy in CI, OPA/Kyverno mentioned |

### 1.4 CI/CD & GitOps

| Skill | Proficiency | Evidence |
|---|---|---|
| **GitHub Actions** (workflows, matrix, reusable, artifacts) | Working ⭐ | All pipelines |
| **OIDC federation** to AWS (no long-lived credentials) | Working | Documented in ADR |
| **ArgoCD** (Applications, ApplicationSets, sync policies, sync waves) | Working ⭐ | Full GitOps loop |
| **GitOps principles** (declarative, versioned, pull-based) | Working | Explained in ADR |
| **Progressive delivery** (canary, blue-green, feature flags) | Familiarity | Documented, one demo |
| **Semantic versioning + Conventional Commits** | Working | Enforced via commitlint |

### 1.5 Observability

| Skill | Proficiency | Evidence |
|---|---|---|
| **OpenTelemetry** (SDKs, Collector, OTLP protocol) | Working ⭐ | All services instrumented |
| **Prometheus** (metrics, PromQL, recording/alerting rules) | Working | Custom rules + alerts |
| **Grafana** (dashboards, provisioning, alerting) | Working | Dashboards as code |
| **Loki** (log aggregation, LogQL) | Familiarity | Centralized logs |
| **Tempo / Jaeger** (distributed tracing) | Working | Trace context propagation |
| **Structured logging** (structlog, correlation IDs) | Working ⭐ | JSON logs everywhere |
| **RED/USE method** for metrics | Working | Applied in dashboards |
| **SLI/SLO/error budgets** | Working ⭐ | Documented per service |

### 1.6 Programming & Backend

| Skill | Proficiency | Evidence |
|---|---|---|
| **Python 3.12** (async/await, typing, pydantic) | Working ⭐ | All services |
| **FastAPI** (routes, dependencies, middleware, background tasks) | Working ⭐ | 3 of 5 services |
| **Pydantic v2** (validation, settings management) | Working ⭐ | All request/response models |
| **asyncpg / SQLAlchemy async** | Working | DB access layer |
| **Redis** (caching, pub/sub, rate limiting) | Working | Rate limiting middleware |
| **pytest** (fixtures, mocks, coverage, testcontainers) | Working ⭐ | 70%+ coverage |
| **Clean Architecture** (layers, DI, testability) | Working | Applied in payment-service |
| **REST API design** (versioning, HATEOAS awareness, idempotency) | Working ⭐ | Explained in API contracts |
| **gRPC basics** | Awareness | Mentioned as alternative |
| **Bash / shell scripting** | Working ⭐ | Automation scripts, git-as |
| **Go basics** | Awareness | Read Kubernetes operators |

### 1.7 Security (DevSecOps)

| Skill | Proficiency | Evidence |
|---|---|---|
| **IAM best practices** (least privilege, MFA, boundaries) | Working ⭐ | Policies in Terraform |
| **Secrets management** (rotation, encryption at rest/transit) | Working | Secrets Manager + External Secrets |
| **SAST** (Bandit, semgrep) | Working | Pipeline integration |
| **DAST** (OWASP ZAP baseline) | Familiarity | Dev environment scan |
| **Container image scanning** (Trivy, Grype) | Working ⭐ | Fail on HIGH/CRITICAL |
| **Dependency scanning** (pip-audit, Dependabot, Snyk) | Working | Automated in CI |
| **IaC security** (Checkov, tfsec) | Working ⭐ | Pipeline integration |
| **Secret detection** (gitleaks, TruffleHog) | Working | Pre-commit + CI |
| **SBOM generation** (syft, SPDX/CycloneDX) | Working | Attached to releases |
| **Supply chain security** (SLSA, Sigstore/cosign) | Familiarity | Documented in ADR |
| **Threat modeling** (STRIDE, DREAD) | Familiarity | Applied to payment-service |
| **Encryption** (at rest, in transit, envelope) | Working | KMS + TLS everywhere |
| **Zero Trust principles** | Awareness | Mentioned in security ADR |

### 1.8 Networking

| Skill | Proficiency | Evidence |
|---|---|---|
| **OSI model / TCP-IP fundamentals** | Working ⭐ | Interview prep |
| **DNS** (records, resolution, propagation) | Working | Route 53 + local dnsmasq |
| **HTTP/1.1 & HTTP/2 & gRPC** | Working | API design |
| **TLS/mTLS** (certificates, ACM, cert-manager) | Working | Ingress TLS |
| **VPC design** (CIDR, subnets, routing, peering, TGW) | Working ⭐ | Network module |
| **Load balancing** (ALB, NLB, algorithms) | Working | ALB via Ingress |
| **CDN concepts** (cache invalidation, edge locations) | Familiarity | CloudFront documented |
| **Service mesh basics** | Awareness | Mentioned in future work |

### 1.9 Data & Storage

| Skill | Proficiency | Evidence |
|---|---|---|
| **PostgreSQL** (indexes, EXPLAIN, connection pooling, replication) | Working ⭐ | Payment DB |
| **DynamoDB modeling** (single-table design basics) | Familiarity | Session store |
| **Redis** (data structures, persistence, cluster) | Working | Cache, rate limit |
| **S3 patterns** (event notifications, lifecycle, replication) | Working | Invoices bucket |
| **Data lake / Iceberg basics** | Awareness | Future work |
| **ETL / Change Data Capture** | Awareness | Debezium mentioned |

### 1.10 Reliability & Chaos Engineering

| Skill | Proficiency | Evidence |
|---|---|---|
| **Chaos engineering principles** (Netflix, Principles of Chaos) | Familiarity | Applied in game days |
| **Toxiproxy** for network fault injection | Working | Latency, loss experiments |
| **chaos-mesh** on Kubernetes | Familiarity | Pod kills, CPU stress |
| **Disaster recovery** (RTO, RPO, strategies: pilot light, warm standby, active-active) | Working ⭐ | DR runbook |
| **Circuit breakers, retries, timeouts, bulkheads** | Working ⭐ | `tenacity` library usage |
| **Backup and restore** strategies | Familiarity | DB backup scripts |
| **Incident response** (blameless post-mortems) | Working ⭐ | 1+ post-mortem written |

### 1.11 AI-Ops & GenAI Integration

| Skill | Proficiency | Evidence |
|---|---|---|
| **LLM API integration** (Ollama, Bedrock, OpenAI-compatible) | Working | AI-Ops agent |
| **Prompt engineering basics** | Familiarity | Diagnostic prompts |
| **Model Context Protocol (MCP)** awareness | Awareness | Mentioned in ADR |
| **RAG basics** (vector DBs, embeddings) | Awareness | Future roadmap |
| **AI-assisted development** (Copilot, Cursor, Claude Code) | Working ⭐ | ADR documenting workflow |

### 1.12 Culture & Frameworks

| Skill | Proficiency | Evidence |
|---|---|---|
| **AWS Well-Architected Framework** (6 pillars) | Working ⭐ | Reviewed against project |
| **ITIL v4** (incident, problem, change management) | Familiarity | Applied in Jira workflows |
| **SRE culture** (SLIs/SLOs, error budgets, toil reduction) | Working ⭐ | SLO doc, blameless PMs |
| **12-Factor App methodology** | Working | Followed in all services |
| **Agile / Scrum basics** | Familiarity | Sprints documented |
| **Blameless post-mortem** structure | Working | Applied |
| **Documentation-as-code** (ADRs, runbooks in git) | Working ⭐ | 7+ ADRs |

### 1.13 FinOps

| Skill | Proficiency | Evidence |
|---|---|---|
| **Infracost** for IaC cost estimation | Working ⭐ | PR comments |
| **AWS Cost Explorer + Budgets + Anomaly Detection** | Familiarity | Documented in runbook |
| **Reserved Instances / Savings Plans / Spot** | Familiarity | Explained in ADR |
| **Right-sizing** (Compute Optimizer, KubeCost) | Familiarity | Applied to k8s |
| **Cost allocation tagging strategy** | Working | Tag policy in TF |
| **Carbon-aware / Green Software** metrics | Awareness | Mentioned in FinOps doc |

---

## 📖 2. English Technical Glossary (must-know vocabulary)

Los términos que **debes poder usar naturalmente** en entrevistas y documentación. Están en inglés porque es como aparecen en JDs y docs oficiales.

### 2.1 Cloud & Infrastructure

| Term | Definition (usa esta explicación en inglés) |
|---|---|
| **Availability Zone (AZ)** | Physically isolated data center within a region |
| **Region** | Geographic area containing multiple AZs |
| **Multi-AZ deployment** | Resources replicated across AZs for HA |
| **Multi-region architecture** | Resources deployed in multiple regions for DR/latency |
| **High Availability (HA)** | System designed to remain operational despite failures |
| **Disaster Recovery (DR)** | Plan to restore service after a major outage |
| **RTO (Recovery Time Objective)** | Max acceptable time to restore service |
| **RPO (Recovery Point Objective)** | Max acceptable data loss window |
| **Failover** | Switching to a standby system when primary fails |
| **Blue/Green deployment** | Two identical environments, switch traffic between them |
| **Canary deployment** | Gradual rollout to a small percentage first |
| **Immutable infrastructure** | Servers are replaced, not modified |
| **Elasticity** | Ability to scale resources up/down automatically |
| **Well-Architected Framework** | AWS's set of best practices (6 pillars) |

### 2.2 Kubernetes & Containers

| Term | Definition |
|---|---|
| **Pod** | Smallest deployable unit in Kubernetes (1+ containers) |
| **Deployment** | Manages ReplicaSets to run N replicas of a Pod |
| **StatefulSet** | Deployment with stable network identity and storage |
| **DaemonSet** | Runs one Pod per node |
| **Service (ClusterIP/NodePort/LoadBalancer)** | Stable network endpoint for Pods |
| **Ingress** | HTTP/S routing rules exposing Services externally |
| **ConfigMap / Secret** | Non-secret / secret config injected into Pods |
| **PersistentVolume (PV) / PersistentVolumeClaim (PVC)** | Storage abstraction |
| **HPA (Horizontal Pod Autoscaler)** | Scales Pod replicas based on metrics |
| **VPA (Vertical Pod Autoscaler)** | Adjusts Pod resource requests |
| **PDB (Pod Disruption Budget)** | Minimum available Pods during voluntary disruptions |
| **RBAC (Role-Based Access Control)** | Authorization model |
| **NetworkPolicy** | Firewall rules for Pod-to-Pod traffic |
| **Sidecar** | Auxiliary container in the same Pod |
| **Init container** | Runs before app containers start |
| **Liveness / Readiness / Startup probe** | Health check types |
| **Rolling update** | Gradual replacement of Pods |
| **Namespace** | Logical partition of a cluster |

### 2.3 Observability

| Term | Definition |
|---|---|
| **Telemetry** | Data emitted by systems: logs, metrics, traces |
| **Cardinality** | Number of unique label combinations in metrics |
| **Distributed tracing** | Following a request across multiple services |
| **Span** | Single unit of work in a trace |
| **Trace context propagation** | Passing trace IDs across service boundaries |
| **SLI (Service Level Indicator)** | Quantitative measure (e.g., request success rate) |
| **SLO (Service Level Objective)** | Target value for an SLI (e.g., 99.9%) |
| **SLA (Service Level Agreement)** | Contract with users (often based on SLOs with buffer) |
| **Error budget** | 100% minus SLO — how much unreliability is acceptable |
| **RED method** | Rate, Errors, Duration (for services) |
| **USE method** | Utilization, Saturation, Errors (for resources) |
| **P50 / P95 / P99 latency** | Percentile latencies (e.g., 99% of requests below X ms) |
| **APM (Application Performance Monitoring)** | Tools like Datadog, New Relic |

### 2.4 CI/CD & Software Delivery

| Term | Definition |
|---|---|
| **Pipeline** | Automated series of build/test/deploy steps |
| **Artifact** | Deployable output of a build (image, binary) |
| **Feature branch** | Short-lived branch for a specific change |
| **Trunk-based development** | Frequent merges to main, short-lived branches |
| **Merge / Squash / Rebase** | Ways to integrate branches |
| **GitOps** | Git as source of truth for infra/apps state |
| **Pull-based deployment** | Cluster pulls desired state (vs push) |
| **Idempotent** | Same input produces same result on repeated runs |
| **Shift-left** | Moving concerns (security, testing) earlier in pipeline |
| **Bake time** | Waiting period after deploy before promoting further |

### 2.5 Reliability & Incident Response

| Term | Definition |
|---|---|
| **Incident** | Unplanned interruption or reduction in service quality |
| **Problem** | Underlying cause of one or more incidents |
| **Change** | Any planned modification to production |
| **Blast radius** | Scope of impact if something fails |
| **Post-mortem / Retrospective** | Analysis after an incident |
| **Blameless culture** | Focus on systems, not people, in RCA |
| **RCA (Root Cause Analysis)** | Process to find underlying cause |
| **MTTR (Mean Time To Recovery)** | Average time to restore service |
| **MTBF (Mean Time Between Failures)** | Average time between failures |
| **Toil** | Manual, repetitive, automatable work |
| **On-call** | Rotation of engineers responsible for incidents |
| **Escalation policy** | Rules for when/how to alert next tier |
| **Runbook** | Step-by-step guide for a known scenario |
| **Playbook** | Higher-level strategy document |
| **Circuit breaker** | Pattern to prevent cascading failures |
| **Bulkhead** | Isolation pattern (like ship compartments) |
| **Graceful degradation** | Reducing functionality vs full failure |

### 2.6 Security

| Term | Definition |
|---|---|
| **Principle of least privilege** | Grant only minimum necessary permissions |
| **Defense in depth** | Multiple layers of security controls |
| **Zero Trust** | Never trust, always verify (identity-based) |
| **CIA triad** | Confidentiality, Integrity, Availability |
| **AAA** | Authentication, Authorization, Accounting |
| **RBAC / ABAC** | Role-based / Attribute-based access control |
| **JWT (JSON Web Token)** | Compact token format for auth claims |
| **OAuth 2.0 / OIDC** | Auth delegation / identity layer |
| **mTLS (mutual TLS)** | Both client and server present certificates |
| **SBOM (Software Bill of Materials)** | Inventory of software components |
| **CVE (Common Vulnerabilities and Exposures)** | Public vulnerability identifier |
| **CVSS** | Vulnerability scoring system |
| **SAST / DAST / SCA** | Static / Dynamic / Composition analysis |
| **Threat model** | Structured analysis of security threats |
| **STRIDE** | Threat classification (Spoofing, Tampering, Repudiation, Info disclosure, DoS, Elevation of privilege) |
| **Attack surface** | Sum of all points where an attacker can attempt entry |

### 2.7 ITIL v4

| Term | Definition |
|---|---|
| **Service Value System (SVS)** | ITIL v4's overall model |
| **Service Value Chain** | Six activities: Plan, Improve, Engage, Design & Transition, Obtain/Build, Deliver & Support |
| **Practice** | Set of resources for performing work (34 practices in ITIL v4) |
| **Incident Management** | Restore normal service ASAP |
| **Problem Management** | Investigate causes to prevent recurrence |
| **Change Enablement** (was Change Management) | Maximize successful changes |
| **Service Request Management** | Handle user-initiated requests |
| **Knowledge Management** | Capture and share information |
| **Continual Improvement** | Ongoing enhancement |
| **CAB (Change Advisory Board)** | Group that reviews changes |
| **RFC (Request for Change)** | Formal proposal for a change |
| **CMDB (Configuration Management Database)** | Inventory of IT assets and relationships |
| **CI (Configuration Item)** | Any component managed in CMDB |
| **Standard change** | Pre-approved, low-risk |
| **Normal change** | Requires assessment and approval |
| **Emergency change** | Urgent, expedited process |

### 2.8 Modern buzzwords que debes usar bien

| Term | Definition | Cuándo usarlo |
|---|---|---|
| **Cloud-native** | Designed to leverage cloud from the start | Descripción del proyecto |
| **Platform Engineering** | Building internal platforms for other devs | Rol futuro objetivo |
| **Internal Developer Platform (IDP)** | Self-service portal for devs | Concepto avanzado |
| **Developer Experience (DevEx)** | How productive/happy devs are | Contexto de plataforma |
| **DORA metrics** | Deployment freq, lead time, MTTR, change fail rate | Métricas de equipo |
| **Chaos Engineering** | Deliberately injecting failures to test resilience | Descripción de práctica |
| **FinOps** | Financial operations for cloud cost management | Práctica reciente |
| **GitOps** | Git-based operations model | Descripción de deploy |
| **Immutable infrastructure** | Servers never modified, only replaced | Approach de deploy |
| **Serverless** | Managed compute abstracting servers | AWS Lambda context |
| **Event-driven architecture** | Systems react to events async | Descripción de arch |
| **Domain-Driven Design (DDD)** | Design based on business domain | Backend design |

---

## ✍️ 3. Communication template en inglés

### 3.1 Commit messages (Conventional Commits)

```
feat(payment): add idempotency key validation for POST /v1/payments
fix(auth): correct JWT expiration handling on refresh
docs(adr): add ADR-0006 for AI-assisted development workflow
refactor(shared): extract structlog config to common module
perf(db): add compound index on (account_id, created_at)
test(payment): add integration tests for DLQ replay
chore(deps): bump pydantic to 2.7.0
ci(security): enable trivy scan on all Dockerfiles
security(payment): sanitize transaction_id to prevent SQL injection
```

Prefixes: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `ci`, `security`, `revert`

### 3.2 Pull Request title & body

**Title:**
```
feat(payment): implement Redis sliding-window rate limiting [NEX-42]
```

**Body:**
```markdown
## Summary
Implements per-user rate limiting on the payment endpoint using
Redis-backed sliding window algorithm. Requests exceeding 100/min
return HTTP 429 with Retry-After header.

## Motivation
Under load testing (k6), the payment endpoint saturated the DB
connection pool at ~800 RPS. Rate limiting protects downstream.

## Changes
- Add `RateLimitMiddleware` in `services/payment-service/src/middleware/`
- Add Redis dependency to `docker-compose.yml`
- Add unit and integration tests
- Update OpenAPI spec

## Testing
- [x] Unit tests: `pytest tests/unit/test_rate_limiter.py`
- [x] Integration tests: `pytest tests/integration/`
- [x] Load test: `k6 run tests/load/rate-limit.js`

## Checklist
- [x] Follows Conventional Commits
- [x] Updates documentation
- [x] No secrets in code
- [x] SAST scan passes (Bandit, Trivy)
- [x] Reviewers assigned: @c-sec @d-ops

Closes NEX-42
```

### 3.3 Incident / post-mortem language

```markdown
# Post-Mortem: INC-1024 — Database Connection Pool Exhaustion

**Date:** 2026-08-11
**Duration:** 12 minutes (10:14 – 10:26 UTC)
**Severity:** SEV-2
**Impact:** 2.4% of transactions failed with HTTP 504
**Author:** D-OPS · Daniela Reyes

## Executive Summary
A traffic spike from a marketing campaign exhausted the payment
service's DB connection pool, causing elevated 5xx errors for
approximately 12 minutes. Auto-scaling was insufficient because
pool size was hardcoded. Service was restored by increasing pool
size via hot config reload.

## Timeline (UTC)
- **10:14** Traffic spike begins (~800 RPS, 8× baseline)
- **10:15** OpenTelemetry alert fires: `p99_latency > 5s`
- **10:16** AI-Ops agent creates NEX-1024 incident in Jira
- **10:18** D-OPS acknowledges page
- **10:20** Pool size increased from 5 to 20 via config reload
- **10:26** Latency returns to baseline

## Contributing Factors
1. Connection pool size was hardcoded, not env-driven
2. No HPA target metric based on DB connection saturation
3. Load testing was insufficient (max 300 RPS tested)

## What Went Well
- AI-Ops agent detected and paged within 2 min
- On-call engineer identified root cause via traces in 4 min
- Blameless response, no user data exposed

## Action Items
| ID | Action | Owner | Due | Status |
|---|---|---|---|---|
| AI-1 | Move pool config to env vars | B-DEV | +1 week | Open |
| AI-2 | Add PgBouncer layer | A-LEAD | +2 weeks | Open |
| AI-3 | Increase load test to 1500 RPS | D-OPS | +1 week | Open |
```

---

## 📎 Cross-references

- Roles that require these skills → `01-career-path-and-roles.md`
- How skills map to certifications → `09-certification-practice-mapping.md`
- Team responsibilities per skill → `03-github-workflow-and-team.md`

---

*Technical Skills Matrix · v1.0*

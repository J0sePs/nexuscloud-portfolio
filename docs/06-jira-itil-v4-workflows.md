# 06 · Jira & ITIL v4 Workflows

> **Objetivo:** aplicar ITIL v4 al proyecto de forma **práctica** — no solo teoría. Vas a configurar Jira Cloud Free, definir workflows por tipo de ticket (Incident, Problem, Change, Service Request), y simular clientes ficticios que reportan problemas para que practiques el ciclo completo.

---

## 🎯 1. ITIL v4 — Concepts que aplicaremos al proyecto

ITIL v4 tiene 34 prácticas. Nosotros aplicamos **8 esenciales** para roles Cloud/DevOps/SRE:

| Practice | Purpose | Where in project |
|---|---|---|
| **Incident Management** | Restore service quickly | Simulated incidents + post-mortems |
| **Problem Management** | Prevent recurrence via RCA | Root cause analysis on repeat incidents |
| **Change Enablement** | Enable changes with acceptable risk | All PRs to `main` classified as changes |
| **Service Request Management** | Handle user-initiated requests | Customer complaint simulator |
| **Knowledge Management** | Capture and reuse insights | Runbooks + ADRs |
| **Monitoring and Event Management** | Detect and respond to events | Prometheus alerts → AI-Ops agent |
| **Continual Improvement** | Ongoing enhancement | Sprint retros → action items |
| **Service Level Management** | Define and monitor service levels | SLI/SLO docs |

### 1.1 Key vocabulary (memorize)

- **Incident**: Any unplanned interruption or reduction in service quality. **Goal: restore service.**
- **Problem**: Cause (or potential cause) of one or more incidents. **Goal: prevent recurrence.**
- **Change**: Addition, modification, or removal of anything that could affect services. **Goal: maximize successful changes.**
- **Service Request**: Any request for information, advice, standard change, or access to a service. **Goal: fulfill efficiently.**
- **Event**: Any occurrence significant for the management of a service.

**Simple mnemonic:**
- 🔥 **Incident** = something broke → fix it now
- 🕵️ **Problem** = why did it break? → investigate to prevent
- 🚧 **Change** = we want to modify something → assess risk first
- 🙋 **Service Request** = user wants something normal → fulfill it

---

## 🛠️ 2. Jira Cloud Free — Setup

### 2.1 Create the site (10 minutes)

1. Go to https://www.atlassian.com/software/jira/free
2. Sign up with your email (free forever for ≤10 users)
3. Site name: `nexuscloud` → URL becomes `https://nexuscloud.atlassian.net`
4. When asked for template, choose **"Scrum"** (we adapt it for ITIL)
5. Project name: `NexusCloud`, Project key: `NEX`

### 2.2 Configure Issue Types

Jira Free has these out of the box: **Task, Story, Bug, Epic**. Extend for ITIL:

Go to Settings → Issues → Issue types → add custom types (if plan allows) or use existing ones creatively:

| Jira Issue Type | ITIL Practice | Custom Label |
|---|---|---|
| **Story** | Feature work | `itil-feature` |
| **Bug** | Bug fix (typically a Problem outcome) | `itil-problem` |
| **Task** | Change or Service Request | `itil-change` / `itil-service-request` |
| **Epic** | Sprint / theme grouping | `itil-epic` |
| **Incident** (custom, if available) | Incident Management | `itil-incident` |

Alternatively (recommended for free tier): use **Task** for everything and rely on **labels + components** to distinguish ITIL practice.

### 2.3 Configure Labels

Add these labels (repeat for every project):

```
Practice labels:
  itil-incident
  itil-problem
  itil-change
  itil-service-request
  itil-knowledge

Priority labels (map to Jira priority):
  P1-critical     → priority: Highest
  P2-high         → priority: High
  P3-medium       → priority: Medium
  P4-low          → priority: Low

Source labels:
  source-monitoring
  source-customer
  source-ai-ops-agent
  source-audit
  source-internal

Component labels:
  comp-payment-service
  comp-auth-service
  comp-notification-service
  comp-ai-ops-agent
  comp-infra
  comp-observability
  comp-security
```

### 2.4 Configure Custom Fields (recommended for realism)

Settings → Issues → Custom fields → add:

- **Severity** (dropdown): SEV-1, SEV-2, SEV-3, SEV-4
- **Blast radius** (short text): "all users" / "10% users" / "specific merchant" / etc.
- **RTO target** (short text): e.g. "3 min"
- **RPO target** (short text): e.g. "30 s"
- **Post-mortem link** (URL)
- **Change type** (dropdown): Standard / Normal / Emergency
- **CAB approval** (checkbox)
- **Rollback plan** (paragraph)

---

## 🔄 3. Workflows per ticket type

### 3.1 Incident workflow

```
   [Detected]
        │
        ▼
   [Triaged]     ← assign, set priority
        │
        ▼
   [In Progress] ← being worked on
        │
        ├──▶ [Mitigated] ← service restored, watch
        │         │
        │         ▼
        │    [Resolved]
        │         │
        │         ▼
        │    [Post-Mortem]  ← required for P1/P2
        │         │
        └─────────┼─▶ [Closed]
                  │
                  └─▶ (if pattern) → escalate to Problem ticket
```

**Fields required per state:**

| State | Required fields |
|---|---|
| Detected | title, description, priority, source, component |
| Triaged | assignee, severity, blast radius |
| In Progress | timeline entries (comments with timestamps) |
| Mitigated | mitigation applied (comment) |
| Resolved | resolution summary, timeline complete |
| Post-Mortem | post-mortem link filled |
| Closed | (auto after post-mortem done or if P3/P4) |

### 3.2 Problem workflow

```
   [Identified]
        │
        ▼
   [Investigating] ← RCA in progress
        │
        ▼
   [Known Error]   ← RCA complete, workaround documented
        │
        ▼
   [Fix Planned]   ← ticket for fix created
        │
        ▼
   [Resolved]
        │
        ▼
   [Closed]
```

**Trigger:** created after Post-Mortem identifies systemic issue, OR when 3+ incidents share root cause.

### 3.3 Change workflow

```
   [Draft RFC]
        │
        ▼
   [Under Review]   ← peer review, C-SEC/D-OPS look
        │
        ├── Standard? ──▶ [Approved]  (auto)
        │
        ├── Normal?   ──▶ [CAB Review] ──▶ [Approved] / [Rejected]
        │
        └── Emergency? ─▶ [Emergency Approval] (post-hoc CAB)
              │
              ▼
        [Scheduled]
              │
              ▼
        [Implementing]
              │
              ▼
        [Verified]     ← post-change verification
              │
              ├── Success ──▶ [Closed]
              │
              └── Failed  ──▶ [Rolled Back] ──▶ Root cause → Problem
```

**PRs to `main` = Normal changes** (require review = CAB).
**Hotfixes = Emergency changes** (documented post-hoc).
**Dependabot version bumps = Standard changes** (pre-approved).

### 3.4 Service Request workflow

```
   [Requested]
        │
        ▼
   [Validated]     ← is this a legit request?
        │
        ▼
   [Fulfilling]
        │
        ▼
   [Fulfilled]
        │
        ▼
   [Closed]        ← user confirms satisfaction
```

Examples: "reset my Grafana password", "add new environment", "grant read access to logs".

---

## 🎫 4. Ticket templates

### 4.1 Incident ticket template (paste in Jira description)

```markdown
## 🔥 Incident Summary
[Short description of what's failing]

## 📊 Impact
- **Users affected:** [count / % / "all"]
- **Services affected:** [payment-service, auth-service, etc.]
- **SLO breach:** [yes/no — which SLO]
- **Financial impact:** [estimate if applicable]

## 🚨 Severity
- [ ] SEV-1 (P1): Complete outage / data loss
- [ ] SEV-2 (P2): Major degradation
- [ ] SEV-3 (P3): Partial impact, workaround exists
- [ ] SEV-4 (P4): Minor issue

## 🔍 Source
- [ ] Monitoring alert (Prometheus)
- [ ] User report / complaint
- [ ] AI-Ops agent auto-detected
- [ ] Manual observation during ops work
- [ ] Security audit finding

## 📅 Timeline (UTC)
| Time | Event | Actor |
|------|-------|-------|
| HH:MM | Incident detected | D-OPS |
| HH:MM | Triage started | ... |
| HH:MM | Mitigation applied | ... |
| HH:MM | Service restored | ... |

## 🔄 Current Status
[What's the state right now?]

## 🛠️ Actions Taken
1. ...
2. ...

## 📋 Next Steps
- [ ] Confirm sustained recovery (30 min observation)
- [ ] Write post-mortem (required for SEV-1, SEV-2)
- [ ] Update runbook (if new scenario)
- [ ] Create Problem ticket (if pattern)

## 🔗 Related
- Correlation ID: [id]
- Grafana dashboard: [link]
- Trace link: [Tempo link]
- Slack thread: [n/a — simulated]
```

### 4.2 Change ticket (RFC) template

```markdown
## 🚧 Change Request

## Change Type
- [ ] **Standard** — pre-approved, low risk, routine
- [ ] **Normal** — requires review and approval
- [ ] **Emergency** — urgent, expedited process

## What is being changed?
[Concise description]

## Justification
[Why is this change needed? Business/technical driver]

## Risk Assessment
- **Blast radius:** [scope of impact if fails]
- **Downtime expected:** [duration or "none"]
- **Rollback complexity:** [Low/Medium/High]

## Implementation Plan
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Rollback Plan
1. [Rollback step 1]
2. [Rollback step 2]

## Testing Done
- [ ] Local (kind cluster)
- [ ] Dev environment
- [ ] Chaos test where relevant
- [ ] Rollback tested

## CAB Members Consulted
- [ ] A-LEAD (Tech Lead)
- [ ] C-SEC (Security)
- [ ] D-OPS (SRE)

## Approval
- [ ] Approved by [A-LEAD] on [date]

## Scheduled Window
- **Start:** [YYYY-MM-DD HH:MM UTC]
- **End:** [YYYY-MM-DD HH:MM UTC]
```

### 4.3 Post-Mortem template (linked from Incident)

```markdown
# Post-Mortem: INC-XXXX — [Short title]

**Date of incident:** YYYY-MM-DD
**Duration:** X min (HH:MM – HH:MM UTC)
**Severity:** SEV-N
**Author:** [D-OPS / A-LEAD]
**Reviewers:** [C-SEC, A-LEAD, ...]

## Executive Summary
[3-4 sentence summary anyone can read]

## Impact
- Users affected: X
- SLO breach: [yes/no]
- Financial impact: [estimate]

## Timeline (UTC)
| Time | Event |
|------|-------|
| HH:MM | ... |

## Contributing Factors
[Not "root cause" singular — multiple factors usually]
1. ...
2. ...

## What Went Well
- [Positive observation]

## What Went Poorly
- [Honest weakness]

## Where We Got Lucky
- [What could have been worse but wasn't]

## Root Cause Analysis (5 Whys)
Q1: Why did the service fail?
A1: ...
Q2: Why did that happen?
A2: ...
[continue until you reach systemic cause]

## Action Items
| ID | Action | Owner | Due | Priority | Status |
|----|--------|-------|-----|----------|--------|
| AI-1 | ... | B-DEV | +1 wk | P2 | Open |
| AI-2 | ... | D-OPS | +2 wk | P3 | Open |

## Lessons Learned (add to knowledge base)
- ...

**Blameless statement:** This post-mortem focuses on systems and
processes. Individual actions are examined only to understand
context, never to assign fault.
```

---

## 🎭 5. Customer Complaint Simulator (the fun part)

Aquí es donde **practicas ITIL de verdad**. Vas a crear "clientes ficticios" que reportan problemas. Cada complaint sigue el flujo completo desde recepción hasta post-mortem.

### 5.1 The fictional customers

Cuatro personajes de cliente que reportan quejas:

| Customer ID | Persona | Company Type | Complaint Style |
|---|---|---|---|
| **CUST-01** | María Palacios | E-commerce (Merchant Grande) | Detallada, técnica, incluye correlation IDs |
| **CUST-02** | Miguel Alarcón | Startup fintech | Vago, urgente, "todo está roto" |
| **CUST-03** | Ana Sung-Lim | Enterprise bank | Formal, escalado por email, exige RCA |
| **CUST-04** | Roberto Cardoza | Small business | Frustrado, poca info técnica, "no funciona" |

Los emails que "envían" son ficticios (guardados en `docs/customer-complaints/`) para tener el input tangible.

### 5.2 20 escenarios de complaints (uno por semana durante 5 meses)

Cada escenario está diseñado para practicar un aspecto distinto de ITIL. Los ejecutas creando el ticket en Jira **y modificando el código para causar/reproducir el problema**, luego resolverlo.

#### 🔴 SEV-1 / SEV-2 Incidents (major)

**Complaint #1 — DB Connection Pool Exhaustion**
- **From:** CUST-01
- **Report:** "Todos los pagos están timing out. Grafana muestra 504s masivos desde las 10:14 UTC."
- **What you do:** create incident ticket, mimic behavior (drop pool size to 2, run load), identify via traces, fix via config, write post-mortem.
- **ITIL practices:** Incident + Problem + Change

**Complaint #2 — Duplicate Charges (Data Integrity)**
- **From:** CUST-03
- **Report:** "Nuestros clientes fueron cargados 2 veces por la misma transacción. Necesitamos RCA formal en 48h."
- **What you do:** simulate missing idempotency key, create incident, implement idempotency layer, write extensive post-mortem.
- **ITIL practices:** Incident + Problem + Change + Emergency Change

**Complaint #3 — Regional Outage**
- **From:** CUST-02
- **Report:** "TODO está caído desde us-east-1!!!"
- **What you do:** simulate DB primary crash, execute DR failover, cronometrize RTO/RPO, post-mortem.
- **ITIL practices:** Incident + Emergency Change

**Complaint #4 — Slow Response Times**
- **From:** CUST-01
- **Report:** "P95 subió de 300ms a 4s en las últimas 3 horas."
- **What you do:** investigate via traces, find a slow query, add index, monitor.
- **ITIL practices:** Incident + Change

**Complaint #5 — 401 Errors Under Load**
- **From:** CUST-04
- **Report:** "Random 401 errors, users can't log in."
- **What you do:** JWT cache miss causing thundering herd on Keycloak, fix with better cache warming.
- **ITIL practices:** Incident + Problem

**Complaint #6 — Notification Emails Not Sent**
- **From:** CUST-02
- **Report:** "Ningún cliente recibió confirmación en las últimas 6h."
- **What you do:** SQS DLQ full of poison pills, need to inspect and fix consumer.
- **ITIL practices:** Incident + Change

#### 🟡 SEV-3 Incidents (moderate)

**Complaint #7 — Intermittent 500 Errors**
- **From:** CUST-01
- **Report:** "~1% de requests fallan aleatoriamente."
- **What you do:** find a race condition in async code, fix with proper locking.

**Complaint #8 — Grafana Dashboard Missing Data**
- **From:** CUST-03 (internal)
- **Report:** "El dashboard de payment latency no muestra data desde ayer."
- **What you do:** OTel collector config broken, restore.

**Complaint #9 — API Rate Limit Too Aggressive**
- **From:** CUST-04
- **Report:** "Nos están tirando 429 injustamente."
- **What you do:** rate limiter has bug in sliding window calc.

**Complaint #10 — Certificate Expiration Warning**
- **From:** Internal (D-OPS)
- **Report:** "cert-manager reports TLS cert expiring in 7 days."
- **What you do:** proactive fix, standard change.

#### 🟢 SEV-4 / Service Requests

**Complaint #11 — Merchant Wants New Currency Support (Service Request → Feature)**
- **From:** CUST-01
- **Report:** "Queremos procesar en EUR además de USD."
- **What you do:** service request → feature ticket → change → deploy.

**Complaint #12 — Requesting Access to Logs**
- **From:** CUST-02
- **Report:** "Podemos tener acceso a nuestros logs para debug?"
- **What you do:** service request, IAM policy update.

#### 🕵️ Problem tickets (patterns)

**Problem #1 — Repeated DB Pool Issues**
- After Complaints #1 and #4, notice pattern → Problem ticket.
- Solution: introduce PgBouncer layer.
- Documented in Known Error.

**Problem #2 — Slow Deployments**
- Multiple sprint retros mention deploys taking 15+ min.
- Problem ticket → RCA → introduce artifact caching in CI.

#### 🚧 Change tickets (proactive)

**Change #1 — Terraform → OpenTofu Migration**
- Normal change with CAB approval simulation.
- Documented rollback: pin Terraform version if fails.

**Change #2 — Postgres 15 → 16 Upgrade**
- Normal change, tested in dev first.
- Backup verified, rollback plan documented.

**Change #3 — Kubernetes 1.29 → 1.30 Upgrade**
- Emergency (CVE fix scenario) OR normal (planned).

**Change #4 — Rotate JWT Signing Keys**
- Standard change (pre-approved procedure).

**Change #5 — Add Circuit Breaker to New Downstream**
- Normal change.

**Change #6 — Enable Encryption on S3 Buckets**
- Standard change from security baseline.

### 5.3 Cadence recommendation

**1 complaint per week during Sprints 3-11** (18 weeks × 1 = 18 tickets minimum).

**Distribution:**
- 6 incidents (SEV-1/2)
- 4 incidents (SEV-3)
- 3 problem tickets
- 5 change tickets
- 2 service requests

Al terminar el proyecto: **20+ tickets Jira con timeline realista, resoluciones documentadas, y 3-5 post-mortems bien escritos**. Esto en un CV vale más que 3 certificaciones.

---

## 📥 6. Customer complaint intake process

### 6.1 The workflow

```
1. Customer email arrives (simulated: you write it in docs/customer-complaints/)
        │
        ▼
2. Service Desk (A-LEAD or D-OPS) triages
        │
        ▼
3. Create Jira ticket (Incident/Problem/Change/SR)
        │
        ▼
4. Assign to appropriate team member
        │
        ▼
5. Work per workflow above
        │
        ▼
6. Reply to customer (write "response email" in docs/customer-complaints/)
        │
        ▼
7. Close ticket + link to any post-mortem
```

### 6.2 Customer email template

Save as `docs/customer-complaints/YYYY-MM-DD-CUST-XX-<slug>.md`:

```markdown
---
customer_id: CUST-01
customer_name: María Palacios
company: BigMerchant Corp
severity_perceived: HIGH
received_at: 2026-08-15T14:23:00Z
channel: email
---

# Subject: URGENT — All payment transactions timing out

Hi NexusCloud Support,

We're seeing widespread payment failures across our checkout flow.
Starting around 10:14 UTC today, ~90% of POST /v1/payments requests
are returning HTTP 504 after 30 seconds.

Our Grafana dashboards show this correlates with a spike in queue
depth on your payment queue. Sample correlation-id: `req-abc123-xyz`.

We have a Black Friday campaign running and this is costing us
significant revenue. Please escalate.

Best regards,
María Palacios
Head of Payments, BigMerchant Corp
```

### 6.3 Response email template (after resolution)

Save as `docs/customer-complaints/YYYY-MM-DD-CUST-XX-<slug>-response.md`:

```markdown
# Subject: RE: URGENT — Payment transactions timing out [RESOLVED · INC-1024]

Dear María,

Thank you for reporting the payment timeout issue. We have resolved
the incident. Here is a full summary:

## Incident Overview
- **Detection:** Our monitoring detected elevated P99 latency at
  10:15 UTC, and our AI-Ops agent auto-created incident INC-1024
  at 10:16 UTC.
- **Duration:** 12 minutes (10:14 – 10:26 UTC)
- **Root cause:** Database connection pool was misconfigured
  (limit of 5), unable to serve the traffic spike from your
  campaign.
- **Fix:** Pool size increased to 20 with automatic scaling.

## Impact on Your Account
- Failed transactions during window: 47
- All have been programmatically reprocessed and confirmed
  completed by 10:35 UTC.

## Post-Mortem
A blameless post-mortem is attached (docs/post-mortems/…).

## Preventive Actions
1. PgBouncer connection pooling layer being added (target: Aug 25)
2. Load test coverage increased to 1500 RPS
3. Custom HPA metric on DB connection saturation

We appreciate your patience. Please let me know if you have
any questions.

Best regards,
D-OPS · Daniela Reyes
Site Reliability Engineering
NexusCloud
```

---

## 📊 7. Metrics to track (ITSM KPIs)

Track these in a Grafana dashboard `ITSM Metrics` for the portfolio:

| KPI | Target | Where measured |
|---|---|---|
| **MTTA** (Mean Time To Acknowledge) | < 5 min | Jira: creation → In Progress |
| **MTTR** (Mean Time To Restore) | < 30 min for P1 | Jira: creation → Resolved |
| **Change failure rate** | < 15% | % of changes rolled back |
| **Deployment frequency** | Multiple per day | Argocd + GitHub webhooks |
| **Lead time for changes** | < 1 day | PR opened → merged to main → deployed |
| **Post-mortem completion rate** | 100% for P1/P2 | Jira post-mortem link filled |
| **SLO adherence** | 99.9% availability | Prometheus recording rules |

Estos son las **DORA metrics** + ITIL KPIs. Ponerlos en el CV es oro.

---

## 🏛️ 8. Change Advisory Board (CAB) simulation

For Normal changes, hold a "CAB meeting" once per sprint (15 min mental exercise, documented output):

### 8.1 CAB meeting template

Save in `docs/meetings/cab/YYYY-MM-DD-cab.md`:

```markdown
# Change Advisory Board — YYYY-MM-DD

**Attendees:**
- A-LEAD · Alex Rivera (chair)
- C-SEC · Carla Chen
- D-OPS · Daniela Reyes
- B-DEV · Bruno Torres (as needed)

**Changes reviewed:**

## CHG-045: Postgres 15 → 16 Upgrade
- Type: Normal
- Requested by: A-LEAD
- Risk: Medium
- Rollback plan: pg_dump snapshot, revert in <10 min
- Testing: Passed in dev environment
- CAB verdict: ✅ APPROVED with condition: run during low-traffic window (Sun 03:00 UTC)
- Scheduled: 2026-09-15 03:00 UTC

## CHG-046: Enable mTLS Between Services
- Type: Normal
- Requested by: C-SEC
- Risk: Medium-High (potential to break service mesh)
- Rollback plan: feature flag toggle
- Testing: Not yet done in staging
- CAB verdict: ⛔ DEFERRED — requires staging validation first

## CHG-047: Bump Trivy version in CI
- Type: Standard (pre-approved)
- CAB verdict: ✅ Auto-approved

**Action items:**
- [ ] A-LEAD schedule CHG-045 for 2026-09-15
- [ ] C-SEC set up staging validation for CHG-046

**Next CAB:** 2026-08-29
```

---

## 🎓 9. Knowledge Management practices

Every incident/problem/change should feed knowledge base:

### 9.1 Knowledge article template

Save in `docs/knowledge-base/KB-NNNN-<slug>.md`:

```markdown
# KB-0007: How to diagnose DB connection pool exhaustion

## Symptoms
- HTTP 504 errors on payment endpoints
- Grafana: `pg_pool_available_connections` near 0
- Logs: `sqlalchemy.exc.TimeoutError: QueuePool limit`
- Traces: spans stuck at `db.get_session`

## Diagnosis Steps
1. Check pool metrics: `curl localhost:9090/metrics | grep pg_pool`
2. Check active queries: `SELECT * FROM pg_stat_activity WHERE state='active'`
3. Check slow queries: `SELECT * FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10`

## Resolution
- Short-term: increase pool size via ConfigMap and rolling restart
- Long-term: add PgBouncer + HPA on custom metric

## Related
- Incident: INC-1024
- Post-mortem: docs/post-mortems/2026-08-11-db-pool.md
- Problem: PRB-003
```

---

## 🔗 10. Cross-references

- The 4 personas of your team → `03-github-workflow-and-team.md`
- How incidents map to sprints → `05-project-structure-and-timeline.md`
- SLIs/SLOs referenced → `04-cloud-architecture-design.md`
- Screenshots to capture from Jira → `10-portfolio-github-showcase.md`

---

*Jira & ITIL v4 Workflows · v1.0*

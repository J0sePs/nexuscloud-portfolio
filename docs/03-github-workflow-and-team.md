# 03 · GitHub Workflow & Simulated Team

> **Objetivo:** definir cómo se ve tu repositorio como si un equipo de 4 personas hubiera colaborado en él durante 6 meses. Cubre identidad, branching strategy, commits, PRs, code reviews, y ownership.

---

## 👥 1. The Simulated Team (4 members)

### 1.1 Team roster

| Nickname | Full Name | Email (git) | Role | Primary Responsibilities |
|---|---|---|---|---|
| **A-LEAD** | Alex Rivera | `a.rivera@nexuscloud.local` | Tech Lead / Platform Engineer | Architecture, ADRs, strategic decisions, IaC modules |
| **B-DEV** | Bruno Torres | `b.torres@nexuscloud.local` | Backend Developer | Microservices code, features, unit/integration tests |
| **C-SEC** | Carla Chen | `c.chen@nexuscloud.local` | Security & DevSecOps Engineer | Threat modeling, PR security reviews, supply chain, SAST/DAST |
| **D-OPS** | Daniela Reyes | `d.reyes@nexuscloud.local` | Site Reliability Engineer | Observability, runbooks, on-call, chaos engineering, post-mortems |

> ⚠️ Los emails son fictional. Todos los commits vienen de **tu** cuenta GitHub, pero se firman con estos nombres/emails vía `git config`. La cuenta GitHub no cambia — sólo el "author" del commit.

### 1.2 Personality prompts (para actuar cada rol)

Cuando "cambias de sombrero", **piensa desde este objetivo**:

- **A-LEAD** — *"Is this decision future-proof? Does it match Well-Architected? Where's the ADR?"*
- **B-DEV** — *"Does the code work? Is it tested? Is it clean? Can I ship this today?"*
- **C-SEC** — *"How does an attacker abuse this? Where's the input validated? What's exposed?"*
- **D-OPS** — *"How do I know if this breaks at 3 AM? Is there a runbook? Can I roll back safely?"*

Estos objetivos entran en conflicto natural — ese conflicto **es** el ejercicio de aprendizaje.

---

## 🎭 2. Identity management (git-as script)

### 2.1 The `git-as.sh` script

Guarda en `scripts/git-as.sh` en el repo:

```bash
#!/usr/bin/env bash
# git-as.sh — Switch git identity for simulated team members
# Usage: git-as {a-lead|b-dev|c-sec|d-ops}
# Or:    git-as --show     (show current)
# Or:    git-as --reset    (reset to your default GitHub identity)

DEFAULT_NAME="${GIT_DEFAULT_NAME:-Your Name}"
DEFAULT_EMAIL="${GIT_DEFAULT_EMAIL:-you@example.com}"

case "$1" in
  a-lead|A-LEAD)
    git config user.name "Alex Rivera"
    git config user.email "a.rivera@nexuscloud.local"
    echo "🎩 [A-LEAD] Now committing as Alex Rivera (Tech Lead)"
    ;;
  b-dev|B-DEV)
    git config user.name "Bruno Torres"
    git config user.email "b.torres@nexuscloud.local"
    echo "💻 [B-DEV] Now committing as Bruno Torres (Backend Developer)"
    ;;
  c-sec|C-SEC)
    git config user.name "Carla Chen"
    git config user.email "c.chen@nexuscloud.local"
    echo "🔒 [C-SEC] Now committing as Carla Chen (Security & DevSecOps)"
    ;;
  d-ops|D-OPS)
    git config user.name "Daniela Reyes"
    git config user.email "d.reyes@nexuscloud.local"
    echo "🚨 [D-OPS] Now committing as Daniela Reyes (SRE)"
    ;;
  --show|-s)
    echo "Current identity: $(git config user.name) <$(git config user.email)>"
    ;;
  --reset|-r)
    git config user.name "$DEFAULT_NAME"
    git config user.email "$DEFAULT_EMAIL"
    echo "↩️  Reset to default: $DEFAULT_NAME <$DEFAULT_EMAIL>"
    ;;
  *)
    cat <<EOF
Usage: git-as {a-lead|b-dev|c-sec|d-ops|--show|--reset}

Team members:
  a-lead   Alex Rivera    Tech Lead / Platform Engineer
  b-dev    Bruno Torres   Backend Developer
  c-sec    Carla Chen     Security & DevSecOps Engineer
  d-ops    Daniela Reyes  Site Reliability Engineer

Current: $(git config user.name) <$(git config user.email)>
EOF
    exit 1
    ;;
esac
```

Instalación una sola vez:

```bash
chmod +x scripts/git-as.sh
# Add to your PATH or alias
echo 'alias git-as="$(pwd)/scripts/git-as.sh"' >> ~/.bashrc
source ~/.bashrc
```

### 2.2 Alternativa recomendada: usar `git commit --author`

Si prefieres no cambiar `user.name`/`user.email` globalmente cada vez:

```bash
git commit --author="Alex Rivera <a.rivera@nexuscloud.local>" -m "..."
```

Y define aliases en `~/.gitconfig`:

```
[alias]
    commit-alead = commit --author='Alex Rivera <a.rivera@nexuscloud.local>'
    commit-bdev  = commit --author='Bruno Torres <b.torres@nexuscloud.local>'
    commit-csec  = commit --author='Carla Chen <c.chen@nexuscloud.local>'
    commit-dops  = commit --author='Daniela Reyes <d.reyes@nexuscloud.local>'
```

Uso: `git commit-bdev -m "feat(payment): add rate limiting [NEX-42]"`

---

## 🌳 3. Branching Strategy

### 3.1 Trunk-based development con feature branches

Esta es la estrategia moderna que la mayoría de las empresas 2026 usan (evita el overhead de GitFlow):

```
main (protected, always deployable)
  │
  ├── feat/a-lead/NEX-10-vpc-module
  ├── feat/b-dev/NEX-42-rate-limiting
  ├── fix/c-sec/NEX-51-jwt-validation
  ├── docs/a-lead/NEX-3-adr-opentofu
  ├── chaos/d-ops/NEX-88-latency-game-day
  └── hotfix/d-ops/NEX-99-circuit-breaker
```

### 3.2 Branch naming convention

```
<type>/<nickname>/<ticket>-<short-description>
```

**Types:**
| Prefix | Purpose |
|---|---|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `docs/` | Documentation only |
| `refactor/` | Code restructuring without behavior change |
| `perf/` | Performance improvement |
| `test/` | Adding tests only |
| `chore/` | Tooling, deps, non-functional |
| `ci/` | CI/CD pipeline changes |
| `security/` | Security fixes |
| `chaos/` | Chaos experiments / game days |
| `hotfix/` | Emergency production fix |

**Examples:**
```
feat/b-dev/NEX-42-rate-limiting
fix/c-sec/NEX-51-sqli-transaction-id
docs/a-lead/NEX-3-adr-opentofu
chore/b-dev/NEX-77-bump-pydantic-2.7
security/c-sec/NEX-63-rotate-secrets
```

### 3.3 Branch protection rules on `main`

Configurar en GitHub → Settings → Branches → Add rule for `main`:

- ✅ Require a pull request before merging
- ✅ Require approvals (**minimum 1**)
- ✅ Dismiss stale approvals when new commits are pushed
- ✅ Require review from Code Owners
- ✅ Require status checks to pass
  - `python-ci`
  - `security-scan`
  - `tofu-plan`
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Require linear history (no merge commits)
- ✅ Include administrators (te obligas a ti mismo)

---

## 📝 4. Commit conventions

### 4.1 Conventional Commits

```
<type>(<scope>): <subject> [<ticket>]

<optional body>

<optional footer(s)>
```

**Examples:**

```
feat(payment): add idempotency key validation [NEX-42]

Prevents duplicate charges when clients retry POST /v1/payments.
Uses Redis with 24h TTL for key storage.

Refs: NEX-42
Co-authored-by: Carla Chen <c.chen@nexuscloud.local>
```

```
fix(auth): correct JWT expiration on refresh [NEX-51]

The previous implementation reset expiration to now + TTL,
allowing indefinite refresh. Now respects original iat + max_lifetime.

Fixes: NEX-51
```

```
docs(adr): add ADR-0006 AI-assisted development workflow [NEX-88]
```

### 4.2 Types

| Type | Semver bump | When |
|---|---|---|
| `feat` | MINOR | New feature |
| `fix` | PATCH | Bug fix |
| `perf` | PATCH | Performance |
| `refactor` | none | Code restructuring |
| `docs` | none | Docs only |
| `test` | none | Tests only |
| `build` | none | Build system, deps |
| `ci` | none | CI/CD |
| `chore` | none | Other |
| `revert` | varies | Revert previous |

Breaking changes: add `!` after type/scope or `BREAKING CHANGE:` in footer.

### 4.3 Commit hygiene

- **Small commits.** One logical change per commit.
- **Present tense, imperative.** "add rate limiting" not "added" or "adds".
- **Subject ≤ 72 chars.** Body wrapped at 100.
- **Reference the ticket.** Always `[NEX-XX]`.
- **Signed commits (optional but pro).** `git commit -S` with GPG key.

---

## 🔀 5. Pull Request Workflow

### 5.1 PR lifecycle

```
1. B-DEV creates branch → writes code → opens PR (Draft)
     ↓
2. B-DEV finishes work → marks Ready for Review
     ↓
3. Assigns reviewers based on CODEOWNERS
     ↓
4. C-SEC + D-OPS review (per CODEOWNERS)
     ↓
5. Comments/change requests addressed
     ↓
6. CI passes (python-ci, security-scan, tofu-plan)
     ↓
7. A-LEAD final approve
     ↓
8. Merge via "Squash and merge" (linear history)
     ↓
9. Branch auto-deleted, ticket auto-closed
```

### 5.2 PR title format

```
<type>(<scope>): <subject> [<ticket>]
```

Same as commit subject.

### 5.3 PR template

Guarda como `.github/pull_request_template.md`:

```markdown
## 📋 Summary
<!-- What does this PR do? 2-3 sentences. -->

## 🎫 Related Ticket
Closes NEX-<number>

## 🎯 Type of Change
- [ ] 🚀 New feature (`feat`)
- [ ] 🐛 Bug fix (`fix`)
- [ ] 📚 Documentation (`docs`)
- [ ] ♻️  Refactor (`refactor`)
- [ ] ⚡ Performance (`perf`)
- [ ] 🧪 Tests (`test`)
- [ ] 🔧 CI/Build (`ci`, `build`)
- [ ] 🔒 Security (`security`)
- [ ] 💥 Breaking change

## ✅ Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
- [ ] Load tested (if applicable)

## 🔒 Security Checklist
- [ ] No secrets in code
- [ ] Input validation for user-provided data
- [ ] Least-privilege IAM changes (if any)
- [ ] Dependencies scanned (Trivy, pip-audit)

## 📊 Observability
- [ ] Logs are structured with correlation IDs
- [ ] Metrics/traces added for new code paths
- [ ] Alerts updated (if applicable)

## 📖 Documentation
- [ ] Code comments where non-obvious
- [ ] README updated (if user-facing)
- [ ] ADR written (if architectural decision)
- [ ] Runbook updated (if operational impact)

## 🖼️ Screenshots / Recordings
<!-- If applicable -->

## 👥 Reviewers
- [ ] Security review (C-SEC)
- [ ] Ops review (D-OPS)
- [ ] Architecture approval (A-LEAD)
```

### 5.4 Review templates by role

Guarda templates en `.github/review-templates/`:

#### `security-review.md` (used by C-SEC)

```markdown
### 🔒 Security Review by C-SEC · Carla Chen

**Threat model reference:** `docs/security-model.md#<component>`

**Findings:**
- 🔴 **HIGH** — <describe critical issue>
- 🟡 **MEDIUM** — <describe important issue>
- 🟢 **LOW** — <describe minor issue>
- 💡 **INFO** — <informational note>

**Positive observations:**
- ✅ <what was done well>

**Verdict:** ❌ Request changes / ⚠️ Approve with follow-up / ✅ Approve

**Follow-up tickets to create if merged:**
- NEX-<TBD>: <description>
```

#### `ops-review.md` (used by D-OPS)

```markdown
### 🚨 Operational Review by D-OPS · Daniela Reyes

**SLO impact:** <does this affect any SLO?>

**Observability check:**
- [ ] Structured logging with correlation IDs
- [ ] Metrics exposed and labeled properly
- [ ] Traces propagate context correctly
- [ ] Alerts defined for failure modes

**Reliability check:**
- [ ] Timeouts explicitly set (no infinite waits)
- [ ] Retries with exponential backoff
- [ ] Circuit breaker where appropriate
- [ ] Graceful degradation path documented

**Operational readiness:**
- [ ] Runbook exists or updated
- [ ] Rollback plan clear
- [ ] Feature flag / kill switch available

**Verdict:** ❌ Request changes / ⚠️ Approve with follow-up / ✅ Approve
```

#### `architecture-review.md` (used by A-LEAD)

```markdown
### 🎩 Architecture Review by A-LEAD · Alex Rivera

**Well-Architected pillars impacted:**
- Operational Excellence: <impact>
- Security: <impact>
- Reliability: <impact>
- Performance Efficiency: <impact>
- Cost Optimization: <impact>
- Sustainability: <impact>

**ADR required?** Yes / No — <if yes, link when created>

**Alignment with system design:**
- <comment>

**Future work implications:**
- <comment>

**Verdict:** ❌ Request changes / ⚠️ Approve with follow-up / ✅ Approve
```

---

## 👥 6. CODEOWNERS file

Guarda como `.github/CODEOWNERS`:

```
# NexusCloud CODEOWNERS
# Each line assigns owners to matching paths. Order matters — last match wins.

# Default owners (fallback)
*                                   @a-lead

# Infrastructure as Code
/infra/                             @a-lead @d-ops
/infra/modules/security/            @c-sec @a-lead
/infra/modules/networking/          @a-lead
/kubernetes/                        @d-ops @a-lead
/kubernetes/argocd/                 @a-lead

# Application code
/services/                          @b-dev
/services/payment-service/          @b-dev @c-sec
/services/auth-service/             @b-dev @c-sec
/services/ai-ops-agent/             @b-dev @d-ops
/services/shared/                   @b-dev

# CI/CD & Security
/.github/workflows/                 @a-lead @c-sec
/.github/workflows/security-*.yml   @c-sec
/scripts/                           @a-lead

# Documentation
/docs/adr/                          @a-lead
/docs/runbooks/                     @d-ops
/docs/post-mortems/                 @d-ops
/docs/security-model.md             @c-sec
/docs/slo-sli.md                    @d-ops

# Tests
/tests/chaos/                       @d-ops
/tests/                             @b-dev @d-ops
```

> Como todos los "usuarios" son ficticios (no existen en GitHub), CODEOWNERS aquí es **documentación de intención**. Su valor real es que en las reviews de PR **tú actúas activamente cada rol** al hacer los comentarios. Si quieres que GitHub aplique CODEOWNERS de verdad, puedes mapear los nicknames a tu propia cuenta con `@tu-usuario`.

---

## 🏷️ 7. Labels strategy

Configurar en GitHub Issues + PRs:

### 7.1 Type labels
| Label | Color | Usage |
|---|---|---|
| `type: feature` | #0e8a16 (green) | New capability |
| `type: bug` | #d73a4a (red) | Something broken |
| `type: enhancement` | #a2eeef (light blue) | Improvement |
| `type: docs` | #0075ca (blue) | Documentation |
| `type: security` | #b60205 (dark red) | Security issue |
| `type: chore` | #cfd3d7 (gray) | Maintenance |
| `type: chaos` | #fbca04 (yellow) | Chaos experiment |

### 7.2 Priority labels (ITIL-aligned)
| Label | Color | Usage |
|---|---|---|
| `priority: P1-critical` | #b60205 | Production down |
| `priority: P2-high` | #d93f0b | Significant impact |
| `priority: P3-medium` | #fbca04 | Normal work |
| `priority: P4-low` | #0e8a16 | Nice to have |

### 7.3 ITIL practice labels
| Label | Color | Usage |
|---|---|---|
| `itil: incident` | #d73a4a | Incident ticket |
| `itil: problem` | #7057ff | Problem investigation |
| `itil: change` | #0075ca | Change request |
| `itil: service-request` | #a2eeef | User request |

### 7.4 Status labels
| Label | Usage |
|---|---|
| `status: needs-triage` | Just created |
| `status: in-progress` | Being worked on |
| `status: blocked` | Waiting on something |
| `status: ready-for-review` | PR review needed |
| `status: needs-changes` | Review found issues |

### 7.5 Component labels
| Label | Usage |
|---|---|
| `component: payment-service` | |
| `component: auth-service` | |
| `component: ai-ops-agent` | |
| `component: infra` | |
| `component: observability` | |
| `component: ci-cd` | |

---

## 📄 8. Issue templates

Guarda en `.github/ISSUE_TEMPLATE/`:

### 8.1 `bug_report.md`

```markdown
---
name: Bug Report
about: Report a defect
title: '[BUG] '
labels: 'type: bug, status: needs-triage'
assignees: ''
---

## Description
<!-- Clear description of the bug -->

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
<!-- What should happen -->

## Actual Behavior
<!-- What actually happens -->

## Environment
- Component:
- Version / commit:
- OS / runtime:

## Severity
- [ ] P1 - Production down
- [ ] P2 - Major functionality broken
- [ ] P3 - Minor issue
- [ ] P4 - Cosmetic

## Additional Context
<!-- Logs, screenshots, related tickets -->
```

### 8.2 `feature_request.md`

```markdown
---
name: Feature Request
about: Propose new functionality
title: '[FEAT] '
labels: 'type: feature, status: needs-triage'
---

## Problem Statement
<!-- What user need is this addressing? -->

## Proposed Solution
<!-- High-level approach -->

## Acceptance Criteria
- [ ] Given <context>, when <action>, then <outcome>
- [ ] ...

## Out of Scope
<!-- What is explicitly NOT included -->

## Estimated Complexity
- [ ] XS (< 1 day)
- [ ] S (1-2 days)
- [ ] M (3-5 days)
- [ ] L (1-2 weeks)
- [ ] XL (> 2 weeks — split it)
```

### 8.3 `incident_report.md`

```markdown
---
name: Incident Report
about: Report a production/environment incident (ITIL Incident)
title: '[INC] '
labels: 'itil: incident, status: needs-triage'
---

## Incident Summary
<!-- What is failing? -->

## Impact
- Users affected:
- Services affected:
- SLO breach: Yes / No

## Priority
- [ ] P1 - Critical (service down, data loss)
- [ ] P2 - High (major degradation)
- [ ] P3 - Medium (partial impact)
- [ ] P4 - Low (workaround exists)

## Detected By
- [ ] Monitoring alert
- [ ] User report
- [ ] AI-Ops agent
- [ ] Manual observation

## Initial Symptoms
<!-- What was observed -->

## Timeline (UTC)
- HH:MM — <event>

## Post-Mortem
- [ ] Post-mortem required (create after resolution)
- Link: TBD
```

### 8.4 `change_request.md`

```markdown
---
name: Change Request (RFC)
about: Formal proposal for a change (ITIL Change Enablement)
title: '[CHG] '
labels: 'itil: change, status: needs-triage'
---

## Change Type
- [ ] Standard (pre-approved, low risk)
- [ ] Normal (assessment required)
- [ ] Emergency (urgent, expedited)

## Description
<!-- What is being changed? -->

## Justification
<!-- Why is this change needed? -->

## Risk Assessment
- Blast radius: <scope>
- Rollback plan: <steps>
- Estimated downtime: <if any>

## Implementation Plan
1.
2.
3.

## Testing
- [ ] Tested in dev
- [ ] Tested in staging (if applicable)
- [ ] Rollback tested

## CAB Approval Required?
- [ ] Yes (Normal / Emergency)
- [ ] No (Standard)

## CAB Members Consulted
- [ ] A-LEAD
- [ ] C-SEC
- [ ] D-OPS
```

---

## 🎬 9. A day in the life (example flow)

**Sprint 5, Monday**

```bash
# C-SEC reviews a threat model report and files an incident
git-as c-sec
# Opens issue #NEX-51 (SQL injection risk in transaction_id)
# labels: type: security, priority: P2-high, itil: incident

# B-DEV picks up the ticket
git-as b-dev
git checkout -b fix/b-dev/NEX-51-sqli-transaction-id
# writes fix + tests
git add .
git commit -m "fix(payment): parameterize transaction_id in DB queries [NEX-51]"
git push -u origin fix/b-dev/NEX-51-sqli-transaction-id
gh pr create --title "fix(payment): parameterize transaction_id in DB queries [NEX-51]" \
             --body-file .github/pull_request_template.md \
             --reviewer '@c-sec,@d-ops' \
             --label 'type: bug,priority: P2-high,itil: incident,component: payment-service'

# C-SEC reviews
git-as c-sec
# Comments on PR using .github/review-templates/security-review.md
# Result: ✅ Approve

# D-OPS reviews
git-as d-ops
# Comments using .github/review-templates/ops-review.md
# Result: ⚠️ Approve with follow-up (add SLO alert for future SQLi attempts)

# A-LEAD approves & merges
git-as a-lead
gh pr merge --squash --delete-branch

# NEX-51 auto-closes via "Closes NEX-51" in PR body
```

Todo esto queda **grabado en el historial del repo** con nombres, timestamps, comentarios y decisiones. Es evidencia real de "cómo trabajaste en equipo".

---

## 📊 10. GitHub Projects (Kanban board setup)

Configurar en `github.com/tu-usuario/nexuscloud-portfolio` → Projects → New Project (Board):

**Columns:**
1. 📥 **Backlog** — issues sin priorizar
2. 🎯 **Sprint** — commitidas al sprint actual
3. 🚧 **In Progress** — activamente en trabajo
4. 👀 **In Review** — PR abierto
5. ✅ **Done** — merged en `main`
6. 📦 **Deployed** — desplegado en local/prod (moved after ArgoCD sync)

**Automation:**
- Issue created → Backlog
- Issue labeled `status: in-progress` → In Progress
- PR opened linking issue → In Review
- PR merged → Done
- Auto-move to Deployed after ArgoCD sync (via GitHub Action webhook)

---

## 🔗 11. Cross-references

- Para asignación de tickets Jira ↔ GitHub → `06-jira-itil-v4-workflows.md`
- Para la definición de sprints → `05-project-structure-and-timeline.md`
- Para blueprints de código donde aplicas todo esto → `08-microservices-code-blueprints.md`

---

*GitHub Workflow & Simulated Team · v1.0*

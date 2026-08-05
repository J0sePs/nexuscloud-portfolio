# 09 · Certification Practice Mapping

> **Objetivo:** demostrar que cada componente del proyecto **es** la práctica de las certificaciones AWS. Estudias la teoría y la aplicas en el mismo sprint. Al llegar al examen, ya operaste todo lo que preguntan.

---

## 🎓 1. Certification study strategy

**Regla:** nunca estudies una cert sin construir. Y nunca construyas sin ubicar en qué sección del examen aplica.

**Método (por sprint):**
1. Lee el capítulo del cert que aplica al sprint actual (2-3 horas)
2. Construye la funcionalidad del sprint (10-15 horas)
3. Repasa el capítulo aplicando lo que hiciste (1 hora)
4. Contesta 20 preguntas de práctica del dominio (30 min)

En 12 sprints × 4 h teoría/sprint = **48 horas de estudio + práctica encima**. Alcanza para SAA + Terraform Assoc.

---

## 🎯 2. AWS Solutions Architect Associate (SAA-C03) — MAPPING

Este es el cert de **mayor ROI** para vos. El examen tiene 4 dominios:

### 2.1 Domain 1: Design Secure Architectures (30%)

**Topics covered:**
- IAM users, groups, roles, policies
- IAM federation, IAM Identity Center (SSO)
- Encryption at rest and in transit (KMS, SSL/TLS)
- Secure access to AWS services (VPC endpoints)
- Secrets management
- Network security (SG, NACL, WAF)

**Where in project:**

| Exam topic | Sprint | Module / file |
|---|---|---|
| IAM roles for services (IRSA) | 3, 4 | `infra/modules/security-baseline/`, `kubernetes/apps/*/serviceaccount.yaml` |
| KMS for encryption at rest | 2 | `infra/modules/security-baseline/kms.tf` |
| Secrets Manager | 6 | `infra/modules/security-baseline/secrets.tf`, `kubernetes/platform/external-secrets/` |
| VPC endpoints | 2 | `infra/modules/networking/endpoints.tf` |
| Security groups | 2 | `infra/modules/networking/security-groups.tf` |
| WAF rules | 4 | Documented in ADR + local nginx-ingress ModSec |
| Cognito user pools | 6 | Simulated with Keycloak (documented cloud target) |

**Question you can answer after this project:**
> *"A company hosts a public web app on EC2. The DB has credentials hardcoded in the app. Recommend a solution."*
>
> **You'll answer:** "Move credentials to AWS Secrets Manager, grant the EC2 instance role permission to `secretsmanager:GetSecretValue`, enable automatic rotation, and reference the secret at runtime — no code changes needed for future rotations. IAM policy scoped to the specific secret ARN."

### 2.2 Domain 2: Design Resilient Architectures (26%)

**Topics covered:**
- Design multi-tier, decoupled architectures
- Design highly available and/or fault-tolerant architectures
- DR strategies (backup/restore, pilot light, warm standby, active-active)
- SQS/SNS decoupling
- ECS/EKS/Lambda compute choices

**Where in project:**

| Exam topic | Sprint | Module / file |
|---|---|---|
| SQS + DLQ | 7 | `infra/modules/messaging/`, notification-service |
| Multi-AZ deployment | 2 | `infra/modules/networking/` (3 AZs) |
| Auto Scaling | 4 | HPA on k8s, Karpenter documented in ADR |
| DR strategies | 9, 11 | `docs/runbooks/dr-failover-playbook.md`, ADR |
| Circuit breakers | 9 | `payment-service/tenacity` config |
| Multi-region (Aurora Global DB) | 11 | Documented + local sim |
| CloudFront (edge) | 4 | Documented + nginx-ingress local |

**Question you'll ace:**
> *"An app requires a decoupled architecture between the web tier and a batch processing tier. The batch tier occasionally fails. Design."*
>
> **You'll answer:** "SQS queue between tiers with visibility timeout matching expected processing duration. Configure DLQ with maxReceiveCount=3 to isolate poison pills. Auto Scaling group on the worker tier based on SQS ApproximateNumberOfMessagesVisible metric. Consider FIFO vs Standard based on ordering requirements."

### 2.3 Domain 3: Design High-Performing Architectures (24%)

**Topics covered:**
- Storage: S3 storage classes, EBS types, EFS
- Compute: EC2 instance families, Lambda, Graviton, Spot
- Databases: RDS/Aurora, DynamoDB, ElastiCache
- Networking: CloudFront, Route 53 routing policies

**Where in project:**

| Exam topic | Sprint | File |
|---|---|---|
| S3 lifecycle policies | 2 | `infra/modules/storage/lifecycle.tf` |
| Aurora Serverless v2 | 3 | `infra/modules/data-layer/aurora.tf` |
| ElastiCache Redis | 6 | `infra/modules/data-layer/redis.tf` |
| Read replicas | 11 | DR module |
| CloudFront caching | 4 | Documented + edge module |
| Route 53 routing | 11 | `infra/modules/edge/route53.tf` |
| Graviton (ARM) | 4 | Instance types t4g.* in kind config |

### 2.4 Domain 4: Design Cost-Optimized Architectures (20%)

**Topics covered:**
- Compute cost strategies (Spot, Reserved, Savings Plans)
- Storage cost strategies (S3 IA, Glacier, lifecycle)
- Right-sizing and monitoring costs

**Where in project:**

| Exam topic | Sprint | File |
|---|---|---|
| Right-sizing | 11 | KubeCost integration + FinOps runbook |
| S3 storage classes | 2 | Lifecycle policy in storage module |
| Spot instances | 4 | Node group with Spot capacity documented |
| Infracost in PR | 8 | `.github/workflows/finops-infracost.yml` |
| Tagging strategy | 2 | Tag policy enforced |
| Budget alerts | 11 | Runbook |

### 2.5 SAA-C03 exam prep timeline

Aligned to sprints:

| Week | Study focus | Practice questions |
|---|---|---|
| 4-5 | Domain 1: Security | 40 questions |
| 8-9 | Domain 2: Resilience | 40 questions |
| 12-13 | Domain 3: Performance | 40 questions |
| 16 | Domain 4: Cost | 30 questions |
| 17-18 | Full-length practice exam #1 | 65 questions |
| 19-20 | Weak-area review | 40 questions |
| 21 | Full-length practice exam #2 | 65 questions |
| 22 | **Exam attempt** | — |

**Recommended resources:**
- **Adrian Cantrill** course ($40) — best video content
- **TutorialsDojo** practice exams ($15) — closest to real
- **AWS Skill Builder** free — official docs

---

## 🔧 3. HashiCorp Terraform Associate (003) — MAPPING

**Focus areas:**

| Objective | Where covered |
|---|---|
| Understand IaC concepts | ADR-0002 (OpenTofu vs Terraform) |
| Understand Terraform's purpose | All `/infra/` module design |
| Understand Terraform basics | State, providers, resources — all sprints 2-11 |
| Use CLI commands | `Makefile` targets: init, plan, apply, destroy, fmt, validate |
| Interact with Terraform modules | Module composition in `infra/modules/*` |
| Use HCP Terraform capabilities | Documented in ADR (why not used) |
| Implement + maintain state | S3 + DynamoDB backend, workspace usage |
| Read, generate, modify configuration | Full ecosystem in project |

**Practice exercises you already did:**
- Write custom module with variables, outputs, locals ✅
- Use `for_each` and `count` ✅
- Data sources (fetch VPC, SG IDs) ✅
- `terraform import` an existing resource ✅
- State manipulation (`state mv`, `state rm`) ✅
- Backend migration ✅

**Tip:** the OpenTofu CLI is 99% identical. Study Terraform materials, but recognize OpenTofu-specific features (state encryption, `-exclude`) in an ADR.

---

## ☁️ 4. AWS Developer Associate (DVA-C02) — MAPPING

**If you're going the dev+cloud path.**

### Domains:

| Domain | % | Where in project |
|---|---|---|
| **Deployment** (24%) | CI/CD, CodePipeline concepts | GitHub Actions workflows |
| **Security** (26%) | IAM, KMS, Cognito, secrets | Same as SAA Domain 1 |
| **Development with AWS Services** (30%) | SDK usage, Lambda, DynamoDB, SQS | `services/*` code |
| **Refactoring** (10%) | Migration to serverless, containerization | Payment-service Dockerfile |
| **Monitoring & Troubleshooting** (10%) | X-Ray, CloudWatch | OTel + Tempo local |

**Extra practice with this project:**
- Deploy a Lambda function (auth-service) ✅
- Use boto3 in Python ✅ (implicit in AWS SDK usage patterns)
- API Gateway integration ✅
- CloudFormation basics (read one; project uses OpenTofu) ⚠️

---

## 🛠️ 5. AWS SysOps Associate (SOA-C02) — MAPPING

**If you're going the pure infra/ops path.**

### Domains:

| Domain | % | Where in project |
|---|---|---|
| **Monitoring, Logging, and Remediation** (20%) | CloudWatch alarms, Systems Manager | Grafana alerts + runbooks |
| **Reliability and Business Continuity** (16%) | Backups, DR, HA | Sprint 9, 11 |
| **Deployment, Provisioning, and Automation** (18%) | IaC, CI/CD | Sprints 1-4 |
| **Security and Compliance** (16%) | IAM, encryption | Sprint 8 |
| **Networking and Content Delivery** (18%) | VPC, DNS, CloudFront | Sprint 2, 4 |
| **Cost and Performance Optimization** (12%) | Cost tools | Sprint 11 |

**SOA has a labs portion** — más práctico que teórico. Este proyecto te prepara casi al 100%.

---

## 🚀 6. AWS DevOps Engineer Professional (DOP-C02) — MAPPING (Year 2)

**El salto senior.** Muy alineado a tu proyecto.

### Domains:

| Domain | % | Where in project |
|---|---|---|
| **SDLC Automation** (22%) | CI/CD pipelines, testing | `.github/workflows/` |
| **Configuration Management & IaC** (17%) | Terraform, CloudFormation | `infra/` |
| **Resilient Cloud Solutions** (15%) | Multi-region, DR, self-healing | Sprint 9, 11 |
| **Monitoring & Logging** (15%) | Observability, alarms | Sprint 5 |
| **Incident & Event Response** (14%) | Automated remediation | AI-Ops agent (!!) |
| **Security & Compliance** (17%) | Automated security | Sprint 8 |

**Your AI-Ops agent is literally what Domain "Incident & Event Response" tests.**

---

## 🐳 7. Certified Kubernetes Application Developer (CKAD) — MAPPING

**Aunque no es AWS, es hyper-valioso para roles con "Kubernetes" en el JD.**

CKAD topics:

| Topic | % | Where in project |
|---|---|---|
| Core concepts (Pods, Deployments) | 13% | `kubernetes/apps/*/templates/deployment.yaml` |
| Configuration (ConfigMaps, Secrets) | 18% | ExternalSecrets integration |
| Multi-container Pods (sidecars, init) | 10% | OTel collector sidecar pattern |
| Observability (probes, logging) | 18% | Health endpoints, structlog |
| Pod design (labels, selectors, jobs, HPA) | 20% | HPA + PDB + labels strategy |
| Services & Networking (Services, Ingress, NetworkPolicy) | 13% | Full ingress-nginx setup |
| State persistence (PV, PVC) | 8% | Aurora replaces this concern |

CKAD exam is **hands-on with kubectl** — 2 hours of live tasks. Perfect after sprints 4-5.

---

## 🎨 8. Portfolio artifacts that "prove" certifications

Cuando pases un cert, no basta con el badge digital. Documenta que **lo ejerciste**:

Save in `docs/portfolio/certifications/`:

```
SAA-C03-passed-2026-11-15.md
  - Score: (if provided)
  - Weak areas: [list domains where you struggled]
  - Project components that ARE evidence:
    * VPC design → infra/modules/networking/
    * IAM least-privilege → infra/modules/security-baseline/
    * DR strategy → docs/runbooks/dr-failover-playbook.md
    * Cost tagging → policy in infra/
```

Y adjunta screenshot del certificado digital.

En el CV:
```
CERTIFICATIONS
────────────────────────────────────────────────────────
AWS Certified Solutions Architect - Associate (SAA-C03)
  Issued Nov 2026 · Verify: [Credly link]
  Applied via nexuscloud-portfolio: VPC design, IAM policies,
  multi-AZ RDS, S3 lifecycle policies (see repo).
```

---

## 📚 9. Practice question sources

**Free:**
- **AWS Skill Builder** — Enroll in the specific cert path
- **ExamPro** free tier — video + questions
- **r/AWSCertifications** subreddit — shared question banks

**Paid ($15-40, worth it):**
- **TutorialsDojo Practice Exams** — closest to real, best explanations
- **Whizlabs** — larger question pool
- **Stephane Maarek Practice Exams** on Udemy — creator of top courses

**Do NOT use:**
- Braindumps (illegal, invalidates cert, often outdated)
- Question mills without explanations

---

## 🧠 10. Study rhythm recommendation

**Per sprint (2 weeks):**
- Week 1 (build):
  - Mon-Thu: build sprint deliverables
  - Fri: 30 min cert reading on today's topic
- Week 2 (build + retrospect):
  - Mon-Wed: continue build + tests
  - Thu: 2 hours cert study + 20 practice questions
  - Fri: sprint retro + document what you learned

**Weekend budget (2 hours):**
- Sat AM: 40 practice questions from weak areas
- Sat PM: read 1 whitepaper (AWS Well-Architected pillars)

**Total per cert:**
- SAA: 60-80 hours of study over 4-5 months
- Terraform Assoc: 20-30 hours over 1-2 months
- CKAD: 40-50 hours + hands-on practice
- DOP-C02: 100-120 hours (year 2)

---

## 🎯 11. Bonus: reciprocal AWS-project mapping

**Every AWS whitepaper you read should end with:** *"which file in my project demonstrates this?"*

If you can't answer, either:
1. Add a component to the project, or
2. Add a paragraph to an ADR explaining why you didn't (and what you'd do in production).

That reciprocal habit is what turns junior candidates into engineers who **actually know AWS**.

---

## 🔗 12. Cross-references

- Certification calendar & costs → `01-career-path-and-roles.md`
- Skills matrix (proficiency levels per topic) → `02-technical-skills-matrix.md`
- Sprint schedule aligned to cert prep → `05-project-structure-and-timeline.md`

---

*Certification Practice Mapping · v1.0*

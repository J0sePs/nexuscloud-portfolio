# 01 · Career Path & Target Roles

> **Objetivo:** definir con precisión qué puestos vas a apuntar, qué salarios esperar, y qué certificaciones acompañan tu progresión — para que cada decisión técnica del proyecto esté alineada a la meta profesional.

---

## 🎯 1. Positioning Statement

**Título de posicionamiento (headline):**
> *AWS Cloud & Infrastructure Engineer specializing in production-grade IaC, Kubernetes GitOps, and observability. Python-first, LATAM-based, English-fluent for remote roles.*

**Elevator pitch (30 segundos):**
> *"I design and operate cloud-native platforms on AWS using OpenTofu for infrastructure, EKS for compute, and ArgoCD for GitOps. My focus is on reliability engineering: I build systems that fail safely, recover automatically, and cost less than they should. I document my decisions as ADRs and treat incidents as learning opportunities through blameless post-mortems."*

Memoriza esa frase. La vas a decir en cada llamada con reclutadores.

---

## 🧭 2. Career progression map (2026 → 2030)

```
YEAR 1                YEAR 2                 YEAR 3-4              YEAR 5+
─────────────────────────────────────────────────────────────────────────
Cloud Engineer   ──▶  Cloud Engineer   ──▶   Senior Cloud    ──▶  Principal /
   Jr / Semi-Sr      Semi-Sr / Sr           Engineer / SRE       Staff / Cloud
                                            or Platform Eng      Architect

Compensation (USD, remote LATAM baseline):
$1.8K-3.5K/mo    ──▶  $3K-5K/mo         ──▶  $5K-8K/mo       ──▶  $8K-15K+/mo
```

**Bifurcaciones estratégicas en Año 2-3** (elige una):

| Ruta | Perfil | Salario ceiling 2028 (remoto) |
|---|---|---|
| **Platform Engineering** | Construyes IDPs (Backstage, Crossplane) para devs internos | $9K-14K/mo |
| **Site Reliability Engineering** | On-call, SLO-driven dev, capacity planning | $8K-13K/mo |
| **Cloud Security** | Zero trust, supply chain, compliance | $9K-15K/mo |
| **AI/ML Infrastructure** | MLOps, GPU orchestration, LLMOps | $10K-16K/mo *(mayor crecimiento)* |
| **FinOps** | Cloud cost optimization especializada | $8K-13K/mo |
| **Solutions Architect** | Face-to-customer, pre-sales técnico | $9K-15K/mo + bonos |

---

## 💼 3. Target roles (Year 1)

### Roles principales para postular tras completar el proyecto

| Job Title (typical postings) | JD keywords que buscarás | Cabe tu proyecto |
|---|---|---|
| **Cloud Engineer** / **AWS Cloud Engineer** | AWS, Terraform, Python, CI/CD, Linux | ✅ 100% |
| **DevOps Engineer** | Docker, Kubernetes, GitLab/GitHub Actions, IaC | ✅ 100% |
| **Infrastructure Engineer** | IaC, networking, security, monitoring | ✅ 100% |
| **Platform Engineer (Jr)** | Kubernetes, ArgoCD, Helm, developer experience | ✅ 100% |
| **Site Reliability Engineer (Jr)** | SLI/SLO, observability, incident response | ✅ 95% |
| **Cloud Support Engineer** | AWS, troubleshooting, customer-facing | ✅ 85% (menos "clean arch") |
| **DevSecOps Engineer** | SAST/DAST, container security, IAM | ✅ 90% |
| **Cloud/Data Engineer** híbrido | AWS + Python + SQL + ETL | ⚠️ Añade componente de datos |

### Roles a evitar en Year 1

- **Senior** anything (necesitas 3-5 años reales)
- **Cloud Architect** (rol de 5+ años, decisión organizacional)
- **DBA Cloud** (especialización distinta)
- **Salesforce/ServiceNow Admin** (no es cloud engineering)

---

## 💰 4. Salary reference (Q3 2026)

### LATAM remoto (contractors, USD/mes)

| Role | Junior | Semi-Sr | Senior |
|---|---|---|---|
| Cloud Engineer | $1,800 – $2,800 | $2,800 – $4,000 | $4,000 – $6,500 |
| DevOps Engineer | $2,000 – $3,000 | $3,000 – $4,500 | $4,500 – $7,000 |
| SRE | $2,500 – $3,500 | $3,500 – $5,000 | $5,000 – $8,000 |
| Platform Engineer | $3,000 – $4,000 | $4,000 – $5,500 | $5,500 – $9,000 |
| Cloud Security | $2,500 – $3,800 | $3,800 – $5,500 | $5,500 – $9,000 |

Fuentes cruzadas: Torre, RemoteRocketship, Jobgether, Glassdoor Peru, encuestas Q2 2026.

### USA / Europa remoto (FTE, USD/año)

| Role | Junior | Semi-Sr | Senior |
|---|---|---|---|
| Cloud Engineer | $85K – $115K | $115K – $145K | $145K – $185K |
| DevOps Engineer | $95K – $125K | $125K – $160K | $160K – $200K |
| SRE | $105K – $135K | $135K – $175K | $175K – $230K |
| Platform Engineer | $110K – $140K | $140K – $180K | $180K – $240K |

> ⚠️ Alcanzar tarifas USA/Europa remoto desde Perú requiere típicamente: **inglés B2+ oral fluido**, **experiencia previa demostrable** (mínimo 2 años), y **red profesional en LinkedIn**.

### Perú local (soles/mes, on-site o híbrido)

| Role | Junior | Semi-Sr | Senior |
|---|---|---|---|
| Cloud Engineer | S/ 4,500 – S/ 7,500 | S/ 7,500 – S/ 12,000 | S/ 12,000 – S/ 20,000 |
| DevOps Engineer | S/ 5,000 – S/ 8,500 | S/ 8,500 – S/ 14,000 | S/ 14,000 – S/ 22,000 |

Bancos grandes (BCP, Interbank, BBVA) y consultoras (IBM Perú, Everis-NTT, Indra, Belatrix) pagan en el rango alto del semi-sr/senior.

---

## 🎓 5. AWS certifications roadmap

### Ruta recomendada (con timing y ROI)

```
Month 0 ──────────────────────────────────────────────────────────▶ Month 36+

M0-2:  CLF-C02 (Cloud Practitioner)           $100    ⚡ Fast, optional
M3-5:  SAA-C03 (Solutions Architect Assoc.)   $150    ⭐ HIGHEST ROI
M6-8:  HashiCorp Terraform Associate           $70.50  or:
       LFCT (OpenTofu Associate)               $395    (emerging)
M9-12: DVA-C02 (Developer Associate) OR        $150
       SOA-C02 (SysOps Associate)              $150
Y2:    DOP-C02 (DevOps Pro)                    $300    ⭐ SENIOR JUMP
Y2-3:  SAP-C02 (Solutions Architect Pro)       $300
Y3+:   Specialty: SCS-C02 (Security)           $300    or:
       ANS-C01 (Advanced Networking)           $300
```

### Estrategia práctica

- **No pagues por cursos caros hasta después del SAA.** El proyecto que estás construyendo **es** el mejor "curso práctico".
- Recursos: AWS Skill Builder (gratis), Adrian Cantrill (~$40 por cert), TutorialsDojo practice exams (~$15).
- Approach: **50% teoría + 50% construir**. Lo que aprendes teórico, lo aplicas al proyecto la misma semana.

### Certificaciones NO oficiales pero valiosas

| Cert | Costo | Cuándo | ROI |
|---|---|---|---|
| **CKAD** (Kubernetes App Dev) | $445 (subvenciones disponibles) | Después de fase 4 del proyecto | ⭐⭐⭐⭐ |
| **CKA** (Kubernetes Admin) | $445 | Año 2 | ⭐⭐⭐⭐ |
| **FinOps Certified Practitioner** | $325 | Año 2-3 si vas por FinOps | ⭐⭐⭐ |
| **HashiCorp Vault Associate** | $70.50 | Año 2 si security path | ⭐⭐⭐ |

### Ojo con estas

- **Amazon Q Developer paid subscriptions y IDE plugins reach end of support April 2027.** No la pongas destacada en el CV a partir de 2027.
- **AWS Machine Learning Specialty terminó March 31, 2026.** Reemplazo: **AWS Certified Generative AI Developer - Professional (AIP-C01)**.

---

## 🏢 6. Companies actively hiring (LATAM & remote, Q3 2026)

### Nearshore / staffing con clientes internacionales

- **Globant** — muy activa en cloud/DevOps, contratos LATAM
- **GFT** — banca alemana/inglesa, cloud-native
- **Encora** — LATAM-wide, muchos roles AWS
- **Compass UOL** — Brasil-based, contrata Peru
- **NeuraFlash** — Salesforce/AWS
- **Bluetab** (IBM) — cloud + data
- **Bluelight Consulting** — DevOps/SRE
- **BairesDev** — nombre polémico pero paga y contrata volumen
- **Andela** — cloud engineers seniors principalmente

### Empresas producto con presencia LATAM/remoto

- **Nubank** (Brasil, remoto LATAM)
- **Rappi** (Colombia, tech HQ)
- **Kavak** (México)
- **Mercado Libre** (Argentina, contrata Peru)
- **DiDi Global** (China con hub LATAM)

### Perú local con proyectos internacionales

- **Everis / NTT Data**
- **Indra**
- **Belatrix (Globant)**
- **IBM Perú**
- **Neoris**
- **Canvia**

### Banca peruana (rol híbrido, sueldo estable en soles)

- **BCP** (Banco de Crédito) — muy activo en cloud migration a AWS
- **Interbank** — cloud transformation en curso
- **BBVA Perú** — cloud + Java Spring
- **Scotiabank Perú** — DevOps team activo

---

## 📈 7. Progression signals

**Estás avanzando bien si en 12 meses:**

- [ ] Al menos 1 recruiter LATAM te contactó proactivamente por LinkedIn
- [ ] Pasaste al menos 1 entrevista técnica (aunque no consiguieras el rol)
- [ ] Puedes leer un job posting de 500 palabras y responder "sí puedo hacer esto" con evidencia concreta del proyecto para cada bullet
- [ ] Tienes 2+ menciones/likes de posts técnicos tuyos en LinkedIn de gente que no conoces
- [ ] Puedes explicar en 90 segundos qué es GitOps, qué es un error budget, y por qué elegiste OpenTofu

**Bandera roja si en 12 meses NO tienes:**

- El proyecto público en GitHub
- Al menos SAA aprobado
- Un video demo del proyecto
- CV en formato ATS-friendly de 1 página
- LinkedIn con headline técnico específico

---

## 🌐 8. English proficiency (crítico)

Para roles remotos internacionales, **B2+ oral es no negociable**. Para roles LATAM nearshore, B1 técnico + capacidad de escribir bien alcanza.

### Cómo demostrarlo sin certificaciones caras

- **Publica en LinkedIn en inglés** técnico (Post-mortems resumidos, ADRs traducidos)
- **README, ADRs, commits, tickets** todos en inglés — es la evidencia real
- **Contribuye a open source** con PRs en inglés (repos pequeños, OpenTofu providers, ArgoCD extensions)

### Certificaciones opcionales

- **EF SET** — gratis online, 1 hora, resultado en horas
- **Duolingo English Test** — $60, aceptado por muchas empresas remotas
- **TOEFL / IELTS** — ~$200-$260, gold standard pero overkill para roles tech

---

## 📝 9. CV structure (1-page ATS-friendly)

Estructura recomendada:

```
────────────────────────────────────────────────────────
[Full Name]                                    [City, Country]
[Email] · [LinkedIn URL] · [GitHub URL] · [Portfolio URL]
────────────────────────────────────────────────────────

SUMMARY (3 lines)
────────────────────────────────────────────────────────
AWS Cloud & Infrastructure Engineer with hands-on experience
building production-grade cloud-native platforms using Python,
OpenTofu, Kubernetes, and GitOps workflows.

TECHNICAL SKILLS
────────────────────────────────────────────────────────
Cloud: AWS (EC2, EKS, Lambda, S3, RDS, SQS, IAM, VPC, Route53, CloudFront)
IaC: OpenTofu, Terraform, CloudFormation basics
Containers: Docker, Kubernetes (kind, EKS Auto Mode), Helm, ArgoCD
Languages: Python 3.12, Bash, SQL, HCL, some Go
Observability: OpenTelemetry, Prometheus, Grafana, Loki, Tempo
CI/CD: GitHub Actions, OIDC federation, DevSecOps pipelines
Security: Trivy, Bandit, Checkov, IAM policies, SBOM (SPDX)
Frameworks: Well-Architected, ITIL v4, SRE (SLI/SLO/error budgets)

FEATURED PROJECT
────────────────────────────────────────────────────────
NexusCloud — AWS Cloud-Native Payment Platform (GitHub: link)
• Designed and implemented multi-region architecture on AWS
  (documented; deployed locally via LocalStack + kind) with
  Aurora Global DB failover, achieving simulated RTO < 3 min
  and RPO < 30 s validated through chaos engineering.
• Built GitOps pipeline with ArgoCD and OpenTelemetry
  observability, reducing deployment time from ~15 min manual
  to <3 min via git push automation.
• Developed AI-Ops agent with pluggable LLM interface
  (Ollama/Bedrock) that auto-triages OTel error traces and
  creates ITIL v4 incident tickets in Jira, cutting simulated
  first-response time from 30 min to <2 min.

CERTIFICATIONS
────────────────────────────────────────────────────────
• AWS Certified Solutions Architect – Associate (SAA-C03) — 2026
• HashiCorp Certified: Terraform Associate — 2026

EDUCATION
────────────────────────────────────────────────────────
[Your degree]

LANGUAGES
────────────────────────────────────────────────────────
Spanish (native) · English (B2 / professional working proficiency)
```

**Reglas ATS:**
- Sin gráficos, columnas raras, íconos, colores
- Fuente estándar (Calibri, Arial, Helvetica)
- Exportar como PDF pero probar en https://resumeworded.com o https://enhancv.com/ats-check
- Densidad de keywords: cada bullet debe contener ≥1 keyword del JD

---

## 🎬 10. Interview preparation topics

Para role Cloud/DevOps Jr/Semi-Sr, prepárate para:

**System design junior (30-45 min)**
- Diseñar un URL shortener
- Diseñar un rate limiter
- Diseñar un sistema de notificaciones push
- Escalar un servicio a 10x tráfico

**AWS deep questions**
- Diferencia ECS vs EKS vs Lambda (cuándo usar cada uno)
- Cómo funciona IAM (principals, resources, policies, trust)
- VPC diseño (subnets, NAT, endpoints, TGW)
- Aurora vs RDS vs DynamoDB (tradeoffs)
- Route 53 routing policies

**Kubernetes**
- Pod lifecycle (init containers, probes, terminationGracePeriodSeconds)
- Servicio: ClusterIP vs NodePort vs LoadBalancer vs Ingress
- HPA vs VPA vs Cluster Autoscaler vs Karpenter
- RBAC básico

**SRE / troubleshooting**
- "The app is slow, walk me through debugging"
- Explicar SLI/SLO/SLA con ejemplos
- Post-mortem culture: cómo escribís uno

**Behavioral**
- "Cuéntame de un incidente que resolviste" → usa tu post-mortem simulado
- "Cuéntame una decisión difícil" → usa un ADR del proyecto
- "Cómo priorizas cuando todo es urgente"

---

## 📎 Referencias cruzadas

- Para skills detalladas → `02-technical-skills-matrix.md`
- Para el plan de estudio de certs junto al proyecto → `09-certification-practice-mapping.md`
- Para pulir CV y portfolio → `10-portfolio-github-showcase.md`

---

*Career Path & Target Roles · v1.0*

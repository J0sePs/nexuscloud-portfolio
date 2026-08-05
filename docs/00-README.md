# 📚 NexusCloud Portfolio — Documentation Pack

> **Portfolio profesional para postular a roles de AWS Cloud / Infrastructure / DevOps / SRE / Platform Engineer en el mercado LATAM y remoto internacional 2026-2030.**
>
> Este pack son 11 documentos que en conjunto constituyen la documentación oficial del proyecto `nexuscloud-portfolio`. Cada archivo cubre un ángulo distinto pero se referencian entre sí.

---

## 🎯 Objetivo del proyecto

Construir un **monorepo end-to-end** que un hiring manager pueda revisar en 5 minutos y reconocer patrones de **producción real**: microservicios con clean architecture, Infrastructure as Code, Kubernetes GitOps, observabilidad, DevSecOps, DR/chaos engineering, AI-Ops, y procesos ITIL v4 documentados como si un equipo de 4 personas hubiera operado el sistema durante 6 meses.

**Estrategia:** todo se desarrolla **100% local y gratis** (WSL2 + Docker + LocalStack + kind + Ollama). Al final, 2 semanas opcionales de AWS real (~$60) para capturar evidencia final.

---

## 🗂️ Índice de documentos (orden de lectura recomendado)

| # | Archivo | Contenido | Cuándo leerlo |
|---|---|---|---|
| **00** | `00-README.md` | Este índice | Primero |
| **01** | `01-career-path-and-roles.md` | Puestos objetivo, salarios, certificaciones | Antes de empezar (define el norte) |
| **02** | `02-technical-skills-matrix.md` | Skills 2026-2030 + glosario en inglés técnico | Antes de empezar (define el qué) |
| **03** | `03-github-workflow-and-team.md` | GitHub setup, branch strategy, los 4 personajes | Semana 1 (define el cómo colaborar) |
| **04** | `04-cloud-architecture-design.md` | Diagramas, Well-Architected Framework, threat model | Semana 1-2 (define la arquitectura) |
| **05** | `05-project-structure-and-timeline.md` | Estructura del monorepo + 12 sprints de 2 semanas | Semana 1 (define el plan de ejecución) |
| **06** | `06-jira-itil-v4-workflows.md` | ITIL v4 + Jira Cloud Free + simulador de cliente | Semana 2 (setup) |
| **07** | `07-local-lab-setup.md` | Docker Compose, kind, comandos día-a-día | Semana 1 (setup técnico) |
| **08** | `08-microservices-code-blueprints.md` | 5 microservicios, clean architecture, código base | Semana 3+ (durante desarrollo) |
| **09** | `09-certification-practice-mapping.md` | Cómo cada parte del proyecto responde certs AWS | Continuo (estudio paralelo) |
| **10** | `10-portfolio-github-showcase.md` | Screenshots, video demo, README, LinkedIn | Semanas 22-24 (pulido final) |

---

## ⏱️ Estimación de tiempo total

| Dedicación semanal | Duración total | Perfil típico |
|---|---|---|
| **15 h/semana** | 24 semanas (~6 meses) | Empleado full-time con proyecto paralelo |
| **20 h/semana** | 18-20 semanas (~4.5 meses) | Estudiante / freelance con tiempo parcial |
| **30 h/semana** | 12-14 semanas (~3 meses) | Dedicación intensiva / sabático |
| **40 h/semana** | 8-10 semanas (~2 meses) | Full-time exclusivo |

**Base de cálculo:** ~360-480 horas totales. Distribución aproximada:
- Infraestructura (IaC, Kubernetes, GitOps): **35%**
- Código de microservicios + tests: **25%**
- Observabilidad + chaos engineering: **15%**
- Procesos ITIL + documentación (ADRs, runbooks, post-mortems): **15%**
- Pulido final (video, README, portfolio site): **10%**

> ⚠️ **No aceleres saltándote la documentación.** En entrevistas, un ADR bien escrito vale más que 500 líneas de código.

---

## 🧑‍🤝‍🧑 El equipo simulado (referencia rápida)

| Nickname | Full Name | Role | Área de responsabilidad principal |
|---|---|---|---|
| **A-LEAD** | Alex Rivera | Tech Lead / Platform Engineer | Arquitectura, ADRs, decisiones estratégicas |
| **B-DEV** | Bruno Torres | Backend Developer | Features, código de microservicios, tests |
| **C-SEC** | Carla Chen | Security & DevSecOps Engineer | Threat modeling, PR security reviews, supply chain |
| **D-OPS** | Daniela Reyes | Site Reliability Engineer | Observability, runbooks, on-call, post-mortems |

**Tú (el usuario)** interpretas a los cuatro, alternando "sombreros" según el contexto. El detalle operativo está en `03-github-workflow-and-team.md`.

---

## 🛠️ Stack tecnológico decidido

**Runtime & Language**
- Python 3.12, FastAPI, Pydantic v2, asyncpg, structlog
- Node.js (solo si es necesario para tooling)

**Infrastructure as Code**
- **OpenTofu** (default) — compatible drop-in con Terraform
- Cloud target: AWS (simulado con LocalStack en local)

**Containers & Orchestration**
- Docker, Docker Compose
- **kind** (Kubernetes in Docker) para local
- **EKS Auto Mode** documentado como target cloud

**GitOps & CI/CD**
- ArgoCD, Helm
- GitHub Actions con OIDC federation (documentado)

**Observability**
- OpenTelemetry Collector
- Prometheus + Grafana + Loki + Tempo

**Data**
- PostgreSQL 16 (primary + replica)
- Redis
- MinIO (S3-compatible)

**AI-Ops**
- Ollama (`llama3.2:3b`) local LLM
- Interface abstracta pluggable con AWS Bedrock, Groq, Gemini

**Security & Scanning**
- Trivy, Bandit, Checkov, tfsec, gitleaks, syft (SBOM)

**Chaos Engineering**
- Toxiproxy, chaos-mesh

**Auth (local)**
- Keycloak (sustituye Cognito)

---

## 📖 Cómo usar este pack

1. **Antes de teclear una línea de código:** lee 01, 02, 04, 05. Son la brújula.
2. **Semana 1:** ejecuta el setup de 03 (GitHub) y 07 (lab local).
3. **Semana 2:** setup de 06 (Jira + ITIL) y arranca el primer sprint del calendario en 05.
4. **Semanas 3-20:** desarrollo iterativo siguiendo los sprints de 05. Consulta 08 para blueprints de código.
5. **En paralelo (continuo):** usa 09 para estudiar certificaciones prácticamente mientras construyes.
6. **Semanas 22-24:** pulido según 10.

---

## ✅ Definition of Done del portfolio completo

El proyecto está listo para postular cuando:

- [ ] Los 11 documentos están integrados en el repo
- [ ] Al menos **7 ADRs** en `/docs/adr/`
- [ ] Al menos **3 runbooks** operativos en `/docs/runbooks/`
- [ ] Al menos **1 post-mortem** blameless simulado
- [ ] **12 sprint retros** documentados
- [ ] Al menos **20 tickets Jira** cerrados (mezcla de features, incidents, changes)
- [ ] **5 microservicios** dockerizados y funcionando en kind
- [ ] **Pipeline CI/CD verde** en `main` con badges visibles
- [ ] **Coverage** > 70%
- [ ] **Video demo** de 3-5 min publicado (YouTube unlisted es OK)
- [ ] **README** con diagramas embebidos
- [ ] **Portfolio site** en Cloudflare Pages (opcional pero recomendado)
- [ ] **LinkedIn** actualizado, proyecto en Featured

---

*Documentación oficial · v1.0 · Julio 2026*

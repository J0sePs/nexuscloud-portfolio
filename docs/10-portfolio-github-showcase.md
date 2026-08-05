# 10 · Portfolio GitHub Showcase

> **Objetivo:** convertir el proyecto técnico en un portfolio que un hiring manager pueda **entender en 90 segundos** y decidir invitarte a entrevista. Screenshots, video demo, README, LinkedIn.

---

## 🎯 1. The 90-second test

Un reclutador escanea tu GitHub así:
```
0-15s   : README title + description + badges
15-30s  : Architecture diagram
30-60s  : Scroll through folders, skim structure
60-90s  : Decision — schedule interview or move on
```

Tu meta: en esos 90 segundos, mostrarles **profundidad + orden + evidencia**.

---

## 📸 2. Screenshots checklist

Ubicación en el repo: `docs/portfolio/screenshots/`

Nomenclatura: `NN-<component>-<what>.png` para orden alfanumérico.

### 2.1 Architecture & Design (must have)

| # | Screenshot | Tool | Purpose |
|---|---|---|---|
| 01 | `01-system-architecture.png` | draw.io export | Overall architecture diagram |
| 02 | `02-network-topology.png` | draw.io | VPC, subnets, AZs |
| 03 | `03-data-flow-sequence.png` | Mermaid render | Payment happy path |
| 04 | `04-threat-model.png` | draw.io | STRIDE overlay |

### 2.2 Local lab (proof it runs)

| # | Screenshot | What to capture |
|---|---|---|
| 10 | `10-make-lab-up.png` | Terminal showing `make lab-up` finishing successfully with all URLs printed |
| 11 | `11-docker-ps.png` | `docker ps` showing 15+ healthy containers |
| 12 | `12-kind-get-nodes.png` | `kubectl get nodes` on the local kind cluster |
| 13 | `13-argocd-ui.png` | ArgoCD UI showing apps synced (green) |

### 2.3 Observability (impressive)

| # | Screenshot | What to capture |
|---|---|---|
| 20 | `20-grafana-red-dashboard.png` | Grafana dashboard with RED metrics (rate, errors, duration) under load |
| 21 | `21-grafana-use-dashboard.png` | USE metrics dashboard |
| 22 | `22-tempo-trace-detail.png` | Distributed trace across services with correlation ID visible |
| 23 | `23-loki-log-search.png` | Loki log query showing structured JSON logs with correlation IDs |
| 24 | `24-prometheus-alerts.png` | Prometheus Alertmanager view of SLO alerts |

### 2.4 Chaos engineering (differentiator)

| # | Screenshot | What to capture |
|---|---|---|
| 30 | `30-toxiproxy-latency-injected.png` | Terminal showing `curl -X POST ... /toxics` with response |
| 31 | `31-grafana-latency-spike.png` | Grafana graph showing P99 latency going from 300ms → 3000ms |
| 32 | `32-circuit-breaker-open.png` | Logs / metrics showing circuit breaker state transition |
| 33 | `33-recovery-graph.png` | Grafana graph showing recovery after chaos removed |

### 2.5 CI/CD (professional maturity)

| # | Screenshot | What to capture |
|---|---|---|
| 40 | `40-github-actions-green.png` | GitHub Actions all-green pipeline run |
| 41 | `41-pr-with-reviews.png` | PR page showing multi-role reviews (C-SEC, D-OPS approvals) |
| 42 | `42-infracost-comment.png` | PR with Infracost bot comment showing cost delta |
| 43 | `43-security-scan-fail.png` | A PR that legit failed security scan (evidence you take it seriously) |
| 44 | `44-sbom-artifact.png` | SBOM file attached to a GitHub release |

### 2.6 ITIL / Jira (unique)

| # | Screenshot | What to capture |
|---|---|---|
| 50 | `50-jira-board-kanban.png` | Jira board with tickets across columns |
| 51 | `51-jira-incident-timeline.png` | Incident ticket with detailed timeline in comments |
| 52 | `52-jira-post-mortem-link.png` | Post-mortem doc linked from incident |
| 53 | `53-cab-meeting-doc.png` | CAB meeting notes rendered |
| 54 | `54-customer-complaint-thread.png` | Customer email → ticket → response flow |

### 2.7 AI-Ops (wow factor)

| # | Screenshot | What to capture |
|---|---|---|
| 60 | `60-exception-in-service.png` | Deliberately triggered exception in payment-service logs |
| 61 | `61-ollama-inference.png` | Terminal showing AI-Ops agent calling Ollama and receiving JSON |
| 62 | `62-jira-auto-created-ticket.png` | Jira ticket created by AI-Ops agent, showing diagnosis + remediation |
| 63 | `63-end-to-end-trace.png` | Full sequence: log → OTel → agent → LLM → Jira, in one screenshot montage |

### 2.8 Cost / FinOps (senior signal)

| # | Screenshot | What to capture |
|---|---|---|
| 70 | `70-infracost-breakdown.png` | Detailed cost breakdown of infra |
| 71 | `71-tag-policy-enforced.png` | Terraform plan failing without proper tags |
| 72 | `72-kubecost-dashboard.png` | KubeCost dashboard (if installed) |

**Total target: 30-40 screenshots.** They tell the story of a production-ready project.

---

## 🎬 3. Video demo (5-7 minutes)

### 3.1 Tools (free)

- **OBS Studio** — screen recording (free, cross-platform)
- **Audacity** — audio cleanup (optional)
- **DaVinci Resolve Free** — editing (or Shotcut)
- **YouTube** — hosting (Unlisted setting for portfolio)

### 3.2 Video script structure

Save script as `docs/portfolio/demo-video-script.md`:

```markdown
# NexusCloud Demo Video Script (~6 min)

## 0:00 - 0:30 · Intro slide (Excalidraw board)
"Hi, I'm [Your Name]. This is NexusCloud — a cloud-native
payment platform I built to demonstrate skills as a Cloud &
Infrastructure Engineer. It runs 100% locally on my laptop
using LocalStack, kind, and Docker Compose, but is designed
for AWS multi-region deployment. Let's take a quick tour."

## 0:30 - 1:00 · Architecture (show diagram)
"The platform consists of five microservices in Python:
API Gateway, Auth Service, Payment Service, Notification
Service, and an AI-Ops Agent. Data lives in Postgres,
messaging in SQS, cache in Redis. All observability via
OpenTelemetry into a Grafana/Loki/Tempo stack. GitOps with
ArgoCD deploys everything to a local kind cluster."

## 1:00 - 2:00 · The team & workflow (show GitHub)
"I simulate a team of 4 to practice real collaboration:
Alex (Tech Lead), Bruno (Backend Dev), Carla (Security), and
Daniela (SRE). Each has git identity via a script, and PRs
require reviews from multiple roles.
[Show the CODEOWNERS file, a PR with multi-role reviews,
and the labels strategy.]"

## 2:00 - 3:00 · Deploy via GitOps
"Let me push a change. [Type: git commit, git push.]
Within 3 minutes, ArgoCD detects the change and syncs the
new version. [Show ArgoCD UI turning green, then
kubectl showing new pod.]"

## 3:00 - 4:00 · Observability
"Now let me generate some load. [Run k6 test.]
Here's the RED dashboard showing rate, errors, duration.
Traces propagate end-to-end — you can see a single request
crossing all services with the same correlation ID.
[Show Tempo trace.]"

## 4:00 - 5:00 · Chaos + AI-Ops
"Now let's break something. [Inject latency via Toxiproxy.]
The circuit breaker opens, latency spikes, and — most
importantly — the AI-Ops agent detects the exception in
OTel traces, calls a local LLM via Ollama for diagnosis,
and creates this Jira ticket [show ticket] with a full
ITIL v4 incident structure. Total time: 90 seconds from
error to actionable ticket."

## 5:00 - 5:30 · Documentation
"Every decision is documented as an ADR. Every failure has
a runbook. Every incident gets a blameless post-mortem.
[Show docs folder tree.]"

## 5:30 - 6:00 · Wrap
"Full source at github.com/[user]/nexuscloud-portfolio.
Thanks for watching."
```

### 3.3 Video recording tips

- **Resolution:** 1080p (1920×1080)
- **FPS:** 30 (60 for smooth cursor)
- **Audio:** external mic if possible, or clean up in Audacity
- **Cursor:** enable "show cursor" and maybe cursor highlight in OBS
- **Terminal:** dark theme, large font (14pt+), no personal info visible
- **Zoom:** if showing small UI, zoom OBS view or use browser zoom
- **Cuts:** don't try to record in one take; edit heavily
- **Music:** optional, subtle (YouTube Audio Library has free tracks)

### 3.4 Upload settings

- **Visibility:** Unlisted (share via link only)
- **Title:** `NexusCloud — AWS Cloud & Infrastructure Portfolio Demo`
- **Description:** paste the script + link to repo
- **Chapters:** add timestamps in description

---

## 📄 4. README.md — the killer version

This is the **single most important file** in your repo. Structure:

### 4.1 Recommended structure

```markdown
# 🚀 NexusCloud — Cloud-Native Payment Platform

<div align="center">

<!-- Badges -->
![CI](https://img.shields.io/github/actions/workflow/status/user/repo/python-ci.yml)
![Coverage](https://img.shields.io/badge/coverage-82%25-green)
![License](https://img.shields.io/github/license/user/repo)
![OpenTofu](https://img.shields.io/badge/IaC-OpenTofu-blue)
![Python](https://img.shields.io/badge/Python-3.12-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue)

**A production-grade AWS cloud-native payment platform**
**demonstrating end-to-end IaC, GitOps, Observability,**
**DevSecOps, Chaos Engineering, and AI-Ops workflows.**

[📽️ Video Demo](https://youtu.be/link) · [📚 Docs](./docs) · [🏛️ Architecture](./docs/architecture/overview.md)

</div>

---

## ✨ Highlights

- 🏗️ **Infrastructure as Code**: 100% OpenTofu, multi-region-ready
- ☸️  **Kubernetes GitOps**: ArgoCD auto-syncs from git
- 🔭 **Observability**: OpenTelemetry → Prometheus + Loki + Tempo + Grafana
- 🔒 **DevSecOps**: SAST, DAST, IaC scan, SBOM, all in CI
- 💥 **Chaos Engineering**: Toxiproxy + chaos-mesh validated
- 🤖 **AI-Ops**: LLM-powered incident triage → Jira tickets
- 🎫 **ITIL v4**: Incidents, Problems, Changes documented
- 💰 **FinOps**: Infracost + tagging + Carbon-aware

## 🎬 See it in action

<a href="https://youtu.be/link"><img src="docs/portfolio/screenshots/thumbnail.png" width="600"></a>

## 🏛️ Architecture

<img src="docs/portfolio/screenshots/01-system-architecture.png" width="800">

[Detailed architecture](./docs/architecture/overview.md) · [All 12 ADRs](./docs/adr/) · [Threat Model](./docs/security-model.md)

## ⚡ Quickstart (local, ~10 minutes)

Prerequisites: Docker, WSL2 or Linux, ~16GB RAM

```bash
git clone https://github.com/user/nexuscloud-portfolio.git
cd nexuscloud-portfolio
make bootstrap        # One command: lab up + k8s + argocd + infra applied
```

Verify:
- Grafana → http://localhost:3000
- ArgoCD → `kubectl port-forward -n argocd svc/argocd-server 8090:443`
- Payment API → http://localhost:8000/docs

## 🧑‍🤝‍🧑 Team (simulated for solo practice)

This project uses a **simulated team of 4** to practice real collaboration workflows:

| Nickname | Role | Focus |
|---|---|---|
| A-LEAD (me) | Tech Lead / Platform Engineer | Architecture, ADRs |
| B-DEV | Backend Developer | Microservices, tests |
| C-SEC | Security & DevSecOps | Threat modeling, PR reviews |
| D-OPS | Site Reliability Engineer | Observability, runbooks |

Details: [Team Workflow doc](./docs/03-github-workflow-and-team.md)

## 📊 Metrics

| Metric | Value |
|---|---|
| Code coverage | 82% |
| SLO availability target | 99.9% |
| DR RTO (measured) | < 3 min |
| DR RPO (measured) | < 30 s |
| P95 latency (baseline) | 180 ms |
| P99 latency (baseline) | 420 ms |
| Deployment time | < 3 min via GitOps |

## 🗂️ Documentation Map

- **[Career context](./docs/01-career-path-and-roles.md)** · Roles this project targets
- **[Skills matrix](./docs/02-technical-skills-matrix.md)** · What's demonstrated
- **[GitHub workflow](./docs/03-github-workflow-and-team.md)** · Branching, PRs
- **[Architecture](./docs/04-cloud-architecture-design.md)** · Well-Architected review
- **[Timeline](./docs/05-project-structure-and-timeline.md)** · 12 sprint plan
- **[ITIL workflows](./docs/06-jira-itil-v4-workflows.md)** · Incident/Problem/Change
- **[Local lab](./docs/07-local-lab-setup.md)** · Docker + kind setup
- **[Code blueprints](./docs/08-microservices-code-blueprints.md)** · Clean architecture
- **[Cert mapping](./docs/09-certification-practice-mapping.md)** · SAA/DOP/CKAD prep
- **[Portfolio](./docs/10-portfolio-github-showcase.md)** · How to show this

## 🎓 Certifications this project prepared me for

- ✅ AWS Solutions Architect Associate (SAA-C03) — Nov 2026
- ✅ HashiCorp Terraform Associate — Dec 2026
- 🎯 Next: AWS DevOps Engineer Professional (target Q3 2027)

## 📜 License

MIT · See [LICENSE](./LICENSE)

## 🙋 Contact

- LinkedIn: [linkedin.com/in/yourprofile]
- Email: [you@example.com]
```

---

## 🔗 5. GitHub repo polish

### 5.1 Repository settings

**Settings → General:**
- Description: `AWS Cloud & Infrastructure Portfolio: end-to-end payment platform with IaC, GitOps, Observability, DevSecOps, Chaos Engineering, and AI-Ops. 100% local runnable.`
- Topics: `aws`, `terraform`, `opentofu`, `kubernetes`, `argocd`, `python`, `fastapi`, `devops`, `sre`, `platform-engineering`, `observability`, `chaos-engineering`, `itil`, `portfolio`
- Website: your portfolio site URL
- Enable Issues, Discussions

**Settings → Branches:**
- Protect `main` (rules from doc 03)

**Settings → Actions → General:**
- Allow all actions
- Read/write GITHUB_TOKEN permissions

### 5.2 Repository social preview

- Create a **1280×640 preview image** with the architecture diagram + title
- Upload in Settings → Social preview

### 5.3 GitHub Pages (optional but pro)

Enable Pages from `main` branch `/docs` folder → automatic docs site at `user.github.io/repo`.

---

## 💼 6. LinkedIn strategy

### 6.1 Profile updates

**Headline (280 chars max):**
```
AWS Cloud & Infrastructure Engineer | Python · OpenTofu · Kubernetes · GitOps | Building production-grade cloud-native platforms | Available for remote LATAM/international roles
```

**About section (opening paragraph):**
```
I build production-grade cloud-native platforms on AWS with a focus
on reliability engineering, GitOps automation, and observability.
My work emphasizes documented architectural decisions, blameless
incident culture, and cost-conscious design.

Currently featured project: NexusCloud — a payment platform
demonstrating end-to-end IaC (OpenTofu), Kubernetes GitOps (ArgoCD),
distributed tracing (OpenTelemetry), chaos engineering (Toxiproxy),
and AI-Ops (LLM-powered incident triage). Full source and 6-min
demo video at github.com/[you]/nexuscloud-portfolio.
```

**Featured section:**
1. Pin the GitHub repo (as link)
2. Pin the YouTube demo video
3. Pin your best technical blog post

### 6.2 Post schedule (12 weeks of content from project)

Every 2 weeks, publish one technical post derived from an ADR:

| Week | Topic | Format |
|---|---|---|
| 4 | "Why we chose OpenTofu over Terraform in 2026" | Article, ~600 words |
| 6 | "Multi-account AWS strategy at portfolio scale" | Article + diagram |
| 8 | "EKS Auto Mode vs manual Karpenter: a decision framework" | Short post + image |
| 10 | "GitOps with ArgoCD: 3 lessons from production" | Post |
| 12 | "The blameless post-mortem template we use" | Article |
| 14 | "Chaos engineering as a solo practice" | Post + video clip |
| 16 | "AI-Ops with local LLMs (Ollama) — is it good enough?" | Article |
| 18 | "FinOps in CI: how Infracost changed our PRs" | Short post |
| 20 | "12 ADRs I wish I had before starting a cloud project" | Article |
| 22 | "The 4-person team simulation that shaped my project" | Post |
| 24 | "From zero to portfolio in 6 months: retrospective" | Long article |

**Best practices:**
- Post Tuesdays or Wednesdays, 9 AM your timezone
- Use 3-5 relevant hashtags: `#AWS #DevOps #CloudEngineering`
- Tag technologies mentioned (LinkedIn recognizes them)
- Add 1 image or diagram per post
- Reply to every comment within 24h

### 6.3 Engagement strategy

- Follow: AWS official, HashiCorp, CNCF, Kelsey Hightower, Corey Quinn, Charity Majors, Cindy Sridharan
- Comment thoughtfully on 5 posts/week
- Share 1 industry article/week with your take
- Endorse skills of people you admire (they often reciprocate)

---

## 🌐 7. Portfolio site (Cloudflare Pages)

Optional but very impressive. **Free** on Cloudflare Pages.

### 7.1 Structure

```
portfolio-site/
├── index.html
├── styles.css
└── assets/
    ├── diagrams/
    └── screenshots/
```

### 7.2 Content sections

1. **Hero:** Your photo + headline + CTA (View Project, LinkedIn, Email)
2. **About:** 2-3 paragraphs
3. **Featured project:** NexusCloud with big architecture image + video embed
4. **Case studies:** 3 ADRs rewritten as blog posts
5. **Skills:** visual grid with icons
6. **Certifications:** badges
7. **Contact:** simple form (Formspree free tier)

### 7.3 Deploy

```bash
# Create repo `portfolio-site` on GitHub
# Push HTML
# In Cloudflare dashboard: Pages → Connect to Git → select repo
# Deploy automatically on every push to main
# Custom domain (optional, ~$10/yr): pages.dev → yourdomain.dev
```

---

## 📧 8. CV variations for different jobs

Have 3 versions of your CV:

### 8.1 Cloud Engineer / DevOps focused
Emphasize: OpenTofu, AWS services, CI/CD, GitOps.
Downplay: Backend dev depth.

### 8.2 Platform / SRE focused
Emphasize: Observability, incident response, SLOs, chaos.
Downplay: Feature dev.

### 8.3 Security / DevSecOps focused
Emphasize: Threat modeling, supply chain, SAST/DAST.
Downplay: Business logic.

Same project, different bullets. Same skills matrix, different emphasis.

---

## 🎯 9. Application strategy

### 9.1 Volume + quality

- Apply to **5-10 quality positions per week**, not 50 spray-and-pray
- Custom cover paragraph per application (2-3 sentences maximum)
- Reference **specific** stuff from the JD in your response

### 9.2 Warm intros

Before applying cold:
1. Find someone at the company on LinkedIn (search "AWS" + company)
2. Send a connection request with a **specific** message about their work
3. After they connect, ask for a 15-min informational call
4. In the call, mention you're applying and ask for advice
5. Often they'll refer you internally

**Referrals convert 10x better than cold applications.**

### 9.3 Response tracking

Simple spreadsheet:

| Company | Role | Applied | Status | Referred by | Notes |
|---|---|---|---|---|---|
| Globant | Cloud Eng | 2026-11-15 | Interview 1 done | María R. | Loved the AI-Ops agent |

---

## ⏱️ 10. Timeline: portfolio → first offer

**Realistic** if project is polished:

| Week | Activity |
|---|---|
| Week 0 | Project complete, all screenshots + video done |
| Week 1-2 | LinkedIn optimized, CV variants ready, portfolio site up |
| Week 3-6 | Applying (10-15/week), interviewing (2-3/week) |
| Week 6-10 | Advanced interview rounds, negotiate offers |
| Week 10-12 | Accept offer, notice period |

**Expected numbers:**
- Applications sent: 40-60
- Recruiter screens: 15-25 (40% response rate is great)
- Technical interviews: 8-12
- Onsite/final rounds: 4-6
- Offers: 1-3

If you're **not getting responses**, the issue is usually CV or LinkedIn — not the project. Iterate.

---

## ✅ 11. Final launch checklist

Before applying to your first job:

- [ ] GitHub repo public
- [ ] README with badges, diagram, quickstart
- [ ] Video demo published (unlisted YouTube)
- [ ] 30+ screenshots in `docs/portfolio/screenshots/`
- [ ] All 12 ADRs written
- [ ] At least 1 post-mortem
- [ ] At least 3 runbooks
- [ ] 12 sprint retros documented
- [ ] 20+ Jira tickets closed with linked PRs
- [ ] LinkedIn: headline, About, Featured all updated
- [ ] CV: 3 variants (Cloud, SRE, Security)
- [ ] Portfolio site live (optional)
- [ ] 3 technical blog posts published on LinkedIn
- [ ] Practiced "elevator pitch" out loud 20 times
- [ ] Mock system-design interview done (with a friend or Pramp)

---

## 🔗 12. Cross-references

- The project you're showcasing → `05-project-structure-and-timeline.md`
- The skills you're proving → `02-technical-skills-matrix.md`
- The team you simulated → `03-github-workflow-and-team.md`

---

**Final word:** the portfolio is not "done" when you deploy it. It's done when it **gets you interviews**. Iterate based on feedback. Track application-to-interview rate. Adjust the pitch.

Ship it.

---

*Portfolio GitHub Showcase · v1.0*

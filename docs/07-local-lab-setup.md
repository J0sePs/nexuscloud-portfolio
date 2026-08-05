# 07 · Local Lab Setup

> **Objetivo:** stack completo local para desarrollar sin gastar en AWS. Todo corre en tu WSL2 con Docker + kind + LocalStack. Este documento tiene los archivos exactos que necesitas.

---

## 🖥️ 1. Prerequisites

### 1.1 Host requirements

- **OS:** WSL2 con Ubuntu 22.04+ (o Linux nativo, o macOS)
- **RAM:** mínimo 16 GB (12 GB si sacrificás Ollama)
- **Disk:** 30 GB libres para imágenes Docker + LocalStack persistence
- **CPU:** 4+ cores recomendado

### 1.2 Software prerequisites (install once)

```bash
# Update package index
sudo apt update && sudo apt upgrade -y

# Base tools
sudo apt install -y \
    curl wget git make jq unzip \
    python3 python3-pip python3-venv \
    build-essential

# Docker (via Docker Desktop en Windows, o docker-ce en Linux)
# Verificar: docker info
docker --version
docker compose version

# Terraform CLI + tflocal (LocalStack wrapper)
wget -O- https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# OpenTofu (preferred over Terraform)
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh | \
    sh -s -- --install-method deb

# LocalStack wrappers
pip install --user localstack awscli-local terraform-local
# Add ~/.local/bin to PATH if not already
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc

# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind && sudo mv kind /usr/local/bin/

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ArgoCD CLI (optional but useful)
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd && sudo mv argocd /usr/local/bin/

# k6 (load testing)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg \
    --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] \
    https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt update && sudo apt install -y k6

# GitHub CLI
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

# Security tools
pip install --user bandit checkov pip-audit
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
    sudo sh -s -- -b /usr/local/bin
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/scripts/install.sh | \
    sh -s -- -b /usr/local/bin
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
    sh -s -- -b /usr/local/bin

# Python dev tools
pip install --user poetry ruff mypy pytest pre-commit
```

### 1.3 Verify install

```bash
docker --version                 # 24.0+
docker compose version           # 2.20+
tofu version                     # 1.7+
tflocal --version               # any
kind --version                   # 0.20+
kubectl version --client         # 1.28+
helm version                     # 3.13+
argocd version --client          # 2.9+
k6 version                       # 0.47+
gh --version                     # 2.35+
python3 --version                # 3.12+
poetry --version                 # 1.7+
trivy --version                  # 0.48+
```

---

## 🐳 2. `docker/docker-compose.yml` — Complete lab stack

```yaml
name: nexuscloud-lab

networks:
  nexus:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16

volumes:
  localstack_data:
  pg_primary_data:
  pg_replica_data:
  minio_data:
  grafana_data:
  loki_data:
  prometheus_data:
  ollama_data:
  keycloak_data:

services:
  # ═══════════════════════════════════════════════════════════════
  # AWS SIMULATION
  # ═══════════════════════════════════════════════════════════════
  localstack:
    image: localstack/localstack:latest
    container_name: nexus-localstack
    ports:
      - "4566:4566"
      - "4571:4571"
    environment:
      SERVICES: "s3,sqs,sns,dynamodb,secretsmanager,iam,kms,cloudwatch,events,stepfunctions,lambda,apigateway,cognito-idp,logs,sts"
      DEBUG: 0
      PERSISTENCE: 1
      LAMBDA_EXECUTOR: docker-reuse
      DOCKER_HOST: unix:///var/run/docker.sock
      HOSTNAME_EXTERNAL: localstack
      DATA_DIR: /var/lib/localstack
    volumes:
      - localstack_data:/var/lib/localstack
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      nexus:
        aliases:
          - localstack
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:4566/_localstack/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

  # ═══════════════════════════════════════════════════════════════
  # DATA LAYER
  # ═══════════════════════════════════════════════════════════════
  postgres-primary:
    image: postgres:16-alpine
    container_name: nexus-pg-primary
    environment:
      POSTGRES_USER: nexus
      POSTGRES_PASSWORD: nexus_local_pwd
      POSTGRES_DB: payments
      POSTGRES_INITDB_ARGS: "--data-checksums"
    ports:
      - "5432:5432"
    volumes:
      - pg_primary_data:/var/lib/postgresql/data
      - ./init-db/primary:/docker-entrypoint-initdb.d
    networks: [nexus]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U nexus -d payments"]
      interval: 10s

  postgres-replica:
    image: postgres:16-alpine
    container_name: nexus-pg-replica
    environment:
      POSTGRES_USER: nexus
      POSTGRES_PASSWORD: nexus_local_pwd
      POSTGRES_DB: payments
    ports:
      - "5433:5432"
    volumes:
      - pg_replica_data:/var/lib/postgresql/data
    networks: [nexus]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U nexus"]
      interval: 10s

  redis:
    image: redis:7-alpine
    container_name: nexus-redis
    command: ["redis-server", "--maxmemory", "256mb", "--maxmemory-policy", "allkeys-lru"]
    ports:
      - "6379:6379"
    networks: [nexus]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s

  minio:
    image: minio/minio:latest
    container_name: nexus-minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin_change_me
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks: [nexus]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s

  # ═══════════════════════════════════════════════════════════════
  # AUTH
  # ═══════════════════════════════════════════════════════════════
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    container_name: nexus-keycloak
    command: ["start-dev", "--import-realm"]
    environment:
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: admin_change_me
      KC_HEALTH_ENABLED: "true"
    ports:
      - "8080:8080"
    volumes:
      - keycloak_data:/opt/keycloak/data
      - ./keycloak/realm-export.json:/opt/keycloak/data/import/realm.json:ro
    networks: [nexus]

  # ═══════════════════════════════════════════════════════════════
  # OBSERVABILITY STACK
  # ═══════════════════════════════════════════════════════════════
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: nexus-otel
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml:ro
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8888:8888"   # metrics
      - "8889:8889"   # prometheus exporter
    networks: [nexus]
    depends_on:
      - tempo
      - loki
      - prometheus

  prometheus:
    image: prom/prometheus:latest
    container_name: nexus-prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=7d'
      - '--web.enable-lifecycle'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks: [nexus]

  loki:
    image: grafana/loki:latest
    container_name: nexus-loki
    command: -config.file=/etc/loki/local-config.yaml
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    ports:
      - "3100:3100"
    networks: [nexus]

  tempo:
    image: grafana/tempo:latest
    container_name: nexus-tempo
    command: ["-config.file=/etc/tempo.yaml"]
    volumes:
      - ./tempo.yaml:/etc/tempo.yaml:ro
    ports:
      - "3200:3200"   # tempo
      - "9095:9095"   # tempo grpc
    networks: [nexus]

  grafana:
    image: grafana/grafana-oss:latest
    container_name: nexus-grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin_change_me
      GF_AUTH_ANONYMOUS_ENABLED: "true"
      GF_FEATURE_TOGGLES_ENABLE: traceqlEditor
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    ports:
      - "3000:3000"
    networks: [nexus]
    depends_on:
      - prometheus
      - loki
      - tempo

  # ═══════════════════════════════════════════════════════════════
  # CHAOS ENGINEERING
  # ═══════════════════════════════════════════════════════════════
  toxiproxy:
    image: ghcr.io/shopify/toxiproxy:latest
    container_name: nexus-toxiproxy
    ports:
      - "8474:8474"   # API
      - "26379:26379" # proxy for redis
      - "25432:25432" # proxy for postgres
    networks: [nexus]

  # ═══════════════════════════════════════════════════════════════
  # AI-OPS (Ollama LLM local)
  # ═══════════════════════════════════════════════════════════════
  ollama:
    image: ollama/ollama:latest
    container_name: nexus-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    networks: [nexus]
    # After first up: docker exec nexus-ollama ollama pull llama3.2:3b

  # ═══════════════════════════════════════════════════════════════
  # EMAIL TESTING
  # ═══════════════════════════════════════════════════════════════
  mailhog:
    image: mailhog/mailhog:latest
    container_name: nexus-mailhog
    ports:
      - "1025:1025"   # SMTP
      - "8025:8025"   # web UI
    networks: [nexus]
```

---

## 📝 3. Supporting config files

### 3.1 `docker/otel-collector-config.yaml`

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024
  memory_limiter:
    check_interval: 1s
    limit_mib: 512

exporters:
  prometheus:
    endpoint: 0.0.0.0:8889
  loki:
    endpoint: http://loki:3100/loki/api/v1/push
  otlp/tempo:
    endpoint: tempo:4317
    tls:
      insecure: true
  debug:
    verbosity: normal

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp/tempo]
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [loki]
```

### 3.2 `docker/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'otel-collector'
    static_configs:
      - targets: ['otel-collector:8889']

  - job_name: 'payment-service'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['host.docker.internal:8000']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

### 3.3 `docker/tempo.yaml`

```yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

ingester:
  trace_idle_period: 10s
  max_block_bytes: 1_000_000
  max_block_duration: 5m

compactor:
  compaction:
    block_retention: 24h

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo/blocks
```

### 3.4 `docker/loki-config.yaml`

```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2024-01-01
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

limits_config:
  retention_period: 168h
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20
```

### 3.5 `kubernetes/kind-config.yaml`

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: nexus
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 8081
        protocol: TCP
      - containerPort: 443
        hostPort: 8443
        protocol: TCP
      - containerPort: 30080
        hostPort: 30080
        protocol: TCP
  - role: worker
    labels:
      workload: general
  - role: worker
    labels:
      workload: general
```

---

## 🔧 4. `Makefile` — orchestrates everything

```makefile
.DEFAULT_GOAL := help
SHELL := /bin/bash

# ═══════════════════════════════════════════════════════════════
# COLORS
# ═══════════════════════════════════════════════════════════════
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# ═══════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════
.PHONY: help
help: ## Show this help
	@echo -e "$(BLUE)NexusCloud — Local Lab Commands$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════
# LAB LIFECYCLE
# ═══════════════════════════════════════════════════════════════
.PHONY: lab-up
lab-up: ## Start the full Docker Compose lab
	@echo -e "$(BLUE)🚀 Starting NexusCloud lab...$(RESET)"
	docker compose -f docker/docker-compose.yml up -d
	@echo -e "$(YELLOW)⏳ Waiting for LocalStack...$(RESET)"
	@until curl -sf http://localhost:4566/_localstack/health > /dev/null 2>&1; do \
	  sleep 2; printf "."; \
	done
	@echo ""
	@echo -e "$(GREEN)✅ Lab is up!$(RESET)"
	@echo -e "  Grafana:    http://localhost:3000 (admin / admin_change_me)"
	@echo -e "  Keycloak:   http://localhost:8080 (admin / admin_change_me)"
	@echo -e "  Prometheus: http://localhost:9090"
	@echo -e "  MinIO:      http://localhost:9001 (minioadmin / minioadmin_change_me)"
	@echo -e "  MailHog:    http://localhost:8025"
	@echo -e "  LocalStack: http://localhost:4566"

.PHONY: lab-down
lab-down: ## Stop the lab (data persists)
	docker compose -f docker/docker-compose.yml down

.PHONY: lab-clean
lab-clean: ## Stop lab and remove all data volumes
	docker compose -f docker/docker-compose.yml down -v

.PHONY: lab-logs
lab-logs: ## Tail logs from all services
	docker compose -f docker/docker-compose.yml logs -f --tail=100

.PHONY: lab-status
lab-status: ## Show status of all services
	docker compose -f docker/docker-compose.yml ps

# ═══════════════════════════════════════════════════════════════
# KUBERNETES
# ═══════════════════════════════════════════════════════════════
.PHONY: k8s-up
k8s-up: ## Create local kind cluster
	@echo -e "$(BLUE)🚀 Creating kind cluster...$(RESET)"
	kind create cluster --config kubernetes/kind-config.yaml
	@echo -e "$(GREEN)✅ Cluster ready$(RESET)"
	@kubectl cluster-info

.PHONY: k8s-down
k8s-down: ## Destroy kind cluster
	kind delete cluster --name nexus

.PHONY: k8s-argocd
k8s-argocd: ## Install ArgoCD in kind
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo -e "$(YELLOW)⏳ Waiting for ArgoCD...$(RESET)"
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
	@echo -e "$(GREEN)✅ ArgoCD ready$(RESET)"
	@echo "Access: kubectl port-forward -n argocd svc/argocd-server 8090:443"
	@echo "Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

.PHONY: k8s-deploy
k8s-deploy: ## Deploy all apps via ArgoCD ApplicationSets
	kubectl apply -f kubernetes/argocd/projects/
	kubectl apply -f kubernetes/argocd/applicationsets/

# ═══════════════════════════════════════════════════════════════
# INFRASTRUCTURE (OpenTofu)
# ═══════════════════════════════════════════════════════════════
.PHONY: tofu-init
tofu-init: ## Initialize OpenTofu backend (LocalStack)
	cd infra/environments/dev && tflocal init

.PHONY: tofu-plan
tofu-plan: ## Plan infra changes
	cd infra/environments/dev && tflocal plan

.PHONY: tofu-apply
tofu-apply: ## Apply infra to LocalStack
	cd infra/environments/dev && tflocal apply -auto-approve

.PHONY: tofu-destroy
tofu-destroy: ## Destroy local infra
	cd infra/environments/dev && tflocal destroy -auto-approve

# ═══════════════════════════════════════════════════════════════
# APPLICATIONS
# ═══════════════════════════════════════════════════════════════
.PHONY: install
install: ## Install Python dependencies
	cd services/shared && poetry install
	cd services/payment-service && poetry install
	cd services/auth-service && poetry install
	cd services/notification-service && poetry install
	cd services/ai-ops-agent && poetry install

.PHONY: run-payment
run-payment: ## Run payment-service locally
	cd services/payment-service && \
	poetry run uvicorn payment_service.main:app --reload --port 8000

.PHONY: build-images
build-images: ## Build all Docker images
	docker build -t nexuscloud/payment-service:local services/payment-service/
	docker build -t nexuscloud/auth-service:local services/auth-service/
	docker build -t nexuscloud/notification-service:local services/notification-service/
	docker build -t nexuscloud/ai-ops-agent:local services/ai-ops-agent/

.PHONY: kind-load-images
kind-load-images: build-images ## Load images into kind
	kind load docker-image nexuscloud/payment-service:local --name nexus
	kind load docker-image nexuscloud/auth-service:local --name nexus
	kind load docker-image nexuscloud/notification-service:local --name nexus
	kind load docker-image nexuscloud/ai-ops-agent:local --name nexus

# ═══════════════════════════════════════════════════════════════
# TESTING
# ═══════════════════════════════════════════════════════════════
.PHONY: test-unit
test-unit: ## Run unit tests for all services
	cd services/payment-service && poetry run pytest tests/unit -v --cov
	cd services/auth-service && poetry run pytest tests/unit -v --cov

.PHONY: test-integration
test-integration: ## Run integration tests (against LocalStack)
	cd services/payment-service && poetry run pytest tests/integration -v

.PHONY: test-load-baseline
test-load-baseline: ## Run baseline load test with k6
	k6 run tests/load/payment-baseline.js

.PHONY: test-load-chaos
test-load-chaos: ## Run load test during chaos
	k6 run tests/load/payment-under-chaos.js

# ═══════════════════════════════════════════════════════════════
# CHAOS ENGINEERING
# ═══════════════════════════════════════════════════════════════
.PHONY: chaos-latency
chaos-latency: ## Inject 2s latency on Redis via Toxiproxy
	curl -X POST http://localhost:8474/proxies \
	  -H 'Content-Type: application/json' \
	  -d '{"name":"redis_proxy","listen":"0.0.0.0:26379","upstream":"redis:6379"}' || true
	curl -X POST http://localhost:8474/proxies/redis_proxy/toxics \
	  -d '{"type":"latency","attributes":{"latency":2000}}'
	@echo -e "$(YELLOW)⚠️  Redis is now 2s slow$(RESET)"

.PHONY: chaos-recover
chaos-recover: ## Remove all chaos experiments
	curl -X DELETE http://localhost:8474/proxies/redis_proxy || true
	@echo -e "$(GREEN)✅ Chaos removed$(RESET)"

.PHONY: chaos-pod-kill
chaos-pod-kill: ## Kill a random payment-service pod
	kubectl delete pod -l app=payment-service -n payment --grace-period=0 --force \
	  $$(kubectl get pod -l app=payment-service -n payment -o jsonpath='{.items[0].metadata.name}')

# ═══════════════════════════════════════════════════════════════
# AI-OPS
# ═══════════════════════════════════════════════════════════════
.PHONY: ollama-pull
ollama-pull: ## Pull the LLM model for AI-Ops agent
	docker exec nexus-ollama ollama pull llama3.2:3b

.PHONY: run-ai-ops
run-ai-ops: ## Run AI-Ops agent locally
	cd services/ai-ops-agent && poetry run python -m ai_ops_agent.main

# ═══════════════════════════════════════════════════════════════
# SECURITY
# ═══════════════════════════════════════════════════════════════
.PHONY: security-scan
security-scan: ## Run all security scanners
	@echo -e "$(BLUE)🔒 Running security scans...$(RESET)"
	@echo -e "$(YELLOW)→ Bandit (SAST Python)$(RESET)"
	-bandit -r services/ -ll
	@echo -e "$(YELLOW)→ Trivy (container scan)$(RESET)"
	-trivy fs services/ --exit-code 0 --severity HIGH,CRITICAL
	@echo -e "$(YELLOW)→ Checkov (IaC scan)$(RESET)"
	-checkov -d infra/ --soft-fail
	@echo -e "$(YELLOW)→ tfsec (IaC scan)$(RESET)"
	-tfsec infra/
	@echo -e "$(YELLOW)→ Gitleaks (secrets in git)$(RESET)"
	-gitleaks detect --source . -v
	@echo -e "$(YELLOW)→ pip-audit (Python deps)$(RESET)"
	-cd services/payment-service && poetry run pip-audit

# ═══════════════════════════════════════════════════════════════
# ONE-LINER SETUPS
# ═══════════════════════════════════════════════════════════════
.PHONY: bootstrap
bootstrap: lab-up k8s-up k8s-argocd tofu-init tofu-apply ## Full first-time setup (~10 min)
	@echo -e "$(GREEN)✅ NexusCloud bootstrap complete$(RESET)"

.PHONY: destroy
destroy: k8s-down lab-clean ## Destroy EVERYTHING (data included)
	@echo -e "$(RED)💥 Everything destroyed$(RESET)"
```

---

## 🎬 5. Day-in-the-life commands

Guide en pared para el día a día:

```bash
# MORNING: start work
make lab-up                      # Docker stack
make k8s-up                      # If not already running

# CHECK STATUS
make lab-status
kubectl get pods -A

# WORK ON A FEATURE
git-as b-dev
git checkout -b feat/b-dev/NEX-42-feature
# ... code, test ...
make test-unit
make test-integration
git commit -m "feat(payment): ... [NEX-42]"
git push
gh pr create

# RUN CHAOS EXPERIMENT
make chaos-latency
make test-load-chaos
# observe Grafana
make chaos-recover

# END OF DAY
make lab-down                    # Optional: save resources
# (keep k8s-up if you'll continue tomorrow)

# NUCLEAR OPTION (start fresh)
make destroy
```

---

## 🔍 6. Troubleshooting común

| Symptom | Cause | Fix |
|---|---|---|
| `docker: no space left` | Volumes fill up | `docker system prune -a --volumes` |
| LocalStack won't start | Port 4566 in use | `sudo lsof -i :4566` → kill offender |
| kind create fails | Existing cluster | `kind delete cluster --name nexus` |
| Ollama OOM | RAM full | Skip Ollama; use Groq/Gemini API |
| Grafana no datasources | Provisioning volume wrong | Check `docker/grafana/provisioning/` mounts |
| `tflocal: command not found` | PATH issue | `export PATH=$PATH:~/.local/bin` |
| Container can't reach `postgres-primary` | Wrong network | Check `networks: [nexus]` in compose |
| Kubernetes pods `ImagePullBackOff` | Image not in kind | `make kind-load-images` |

---

## 📊 7. Resource consumption benchmark

Running everything at once (my measured baseline on WSL2 with 32GB RAM):

| Service | RAM (idle) | CPU (idle) |
|---|---|---|
| LocalStack | ~600 MB | ~2% |
| Postgres × 2 | ~200 MB total | <1% |
| Redis | ~50 MB | <1% |
| MinIO | ~120 MB | <1% |
| Keycloak | ~500 MB | ~3% |
| OTel Collector | ~150 MB | ~1% |
| Prometheus | ~400 MB | ~2% |
| Grafana | ~250 MB | <1% |
| Loki | ~200 MB | <1% |
| Tempo | ~200 MB | <1% |
| Toxiproxy | ~30 MB | <1% |
| Ollama (idle) | ~2 GB | <1% |
| Ollama (inferring 3b model) | ~4 GB | 100% 1 core |
| MailHog | ~20 MB | <1% |
| **TOTAL (with Ollama idle)** | **~4.7 GB** | **~12%** |
| **TOTAL (Ollama inferring)** | **~7 GB** | **spikes to 100%** |

Add kind (2 workers) + apps: another ~2-3 GB.

**Realistic RAM budget:**
- 12 GB total system RAM: works but tight (skip Ollama when not needed)
- 16 GB total: comfortable
- 32 GB total: no worries

---

## 🔗 8. Cross-references

- Architecture behind these containers → `04-cloud-architecture-design.md`
- What to code that runs inside → `08-microservices-code-blueprints.md`
- Sprints that use this lab → `05-project-structure-and-timeline.md`

---

*Local Lab Setup · v1.0*

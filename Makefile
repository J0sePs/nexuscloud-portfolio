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
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-24s$(RESET) %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════
# LAB LIFECYCLE
# ═══════════════════════════════════════════════════════════════
.PHONY: lab-up
lab-up: ## Start the full Docker Compose lab (without Ollama)
	@echo -e "$(BLUE)🚀 Starting NexusCloud lab...$(RESET)"
	docker compose -f docker/docker-compose.yml up -d
	@echo -e "$(YELLOW)⏳ Waiting for LocalStack to be ready...$(RESET)"
	@until curl -sf http://localhost:4566/_localstack/health > /dev/null 2>&1; do \
	  sleep 2; printf "."; \
	done
	@echo ""
	@echo -e "$(GREEN)✅ Lab is up! Access URLs:$(RESET)"
	@echo -e "  Grafana:            http://localhost:3000 (anonymous access enabled)"
	@echo -e "  Prometheus:         http://localhost:9090"
	@echo -e "  Keycloak Admin:     http://localhost:8080 (admin / admin_change_me)"
	@echo -e "  Keycloak Mgmt:      http://localhost:9990 (health, metrics)"
	@echo -e "  MinIO Console:      http://localhost:9001 (minioadmin / minioadmin_change_me)"
	@echo -e "  MinIO API:          http://localhost:9000"
	@echo -e "  MailHog UI:         http://localhost:8025"
	@echo -e "  LocalStack:         http://localhost:4566"
	@echo -e "  Toxiproxy:          http://localhost:8474"
	@echo -e "  Loki:               http://localhost:3100"
	@echo -e "  Tempo:              http://localhost:3200"

.PHONY: lab-up-with-ai
lab-up-with-ai: ## Start lab including Ollama (needs 12GB+ RAM)
	docker compose -f docker/docker-compose.yml --profile ai-ops up -d

.PHONY: lab-down
lab-down: ## Stop the lab (data persists)
	docker compose -f docker/docker-compose.yml down

.PHONY: lab-clean
lab-clean: ## Stop lab and remove all data volumes
	docker compose -f docker/docker-compose.yml down -v
	@echo -e "$(RED)💥 All volumes removed$(RESET)"

.PHONY: lab-logs
lab-logs: ## Tail logs from all services
	docker compose -f docker/docker-compose.yml logs -f --tail=100

.PHONY: lab-logs-service
lab-logs-service: ## Tail logs from a specific service (usage: make lab-logs-service SERVICE=nexus-tempo)
	@if [ -z "$(SERVICE)" ]; then \
	  echo -e "$(RED)❌ Usage: make lab-logs-service SERVICE=<container-name>$(RESET)"; \
	  exit 1; \
	fi
	docker logs -f $(SERVICE) --tail=100

.PHONY: lab-status
lab-status: ## Show status of all services
	docker compose -f docker/docker-compose.yml ps

.PHONY: lab-restart
lab-restart: lab-down lab-up ## Restart the lab

# ═══════════════════════════════════════════════════════════════
# SMOKE TESTS
# ═══════════════════════════════════════════════════════════════
.PHONY: smoke-test
smoke-test: ## Run smoke tests against all services
	@echo -e "$(BLUE)🧪 Running smoke tests...$(RESET)"
	@printf "  LocalStack ......... "; curl -sf http://localhost:4566/_localstack/health > /dev/null && echo "✅" || echo "❌"
	@printf "  Postgres primary ... "; docker exec nexus-pg-primary pg_isready -U nexus > /dev/null 2>&1 && echo "✅" || echo "❌"
	@printf "  Postgres replica ... "; docker exec nexus-pg-replica pg_isready -U nexus > /dev/null 2>&1 && echo "✅" || echo "❌"
	@printf "  Redis .............. "; docker exec nexus-redis redis-cli ping > /dev/null 2>&1 && echo "✅" || echo "❌"
	@printf "  MinIO .............. "; curl -sf http://localhost:9000/minio/health/live > /dev/null && echo "✅" || echo "❌"
	@printf "  Grafana ............ "; curl -sf http://localhost:3000/api/health > /dev/null && echo "✅" || echo "❌"
	@printf "  Prometheus ......... "; curl -sf http://localhost:9090/-/healthy > /dev/null && echo "✅" || echo "❌"
	@printf "  Loki ............... "; curl -sf http://localhost:3100/ready > /dev/null && echo "✅" || echo "❌"
	@printf "  Tempo .............. "; curl -sf http://localhost:3200/ready > /dev/null && echo "✅" || echo "❌"
	@printf "  Keycloak ........... "; curl -sf http://localhost:9990/health/ready > /dev/null 2>&1 && echo "✅" || echo "⚠️  starting (takes ~60s)"
	@printf "  MailHog ............ "; curl -sf http://localhost:8025 > /dev/null && echo "✅" || echo "❌"
	@printf "  Toxiproxy .......... "; curl -sf http://localhost:8474/version > /dev/null && echo "✅" || echo "❌"

.PHONY: smoke-test-strict
smoke-test-strict: ## Run smoke tests and exit non-zero on any failure (useful for CI)
	@FAILED=0; \
	for check in \
	  "LocalStack:curl -sf http://localhost:4566/_localstack/health" \
	  "Postgres-primary:docker exec nexus-pg-primary pg_isready -U nexus" \
	  "Postgres-replica:docker exec nexus-pg-replica pg_isready -U nexus" \
	  "Redis:docker exec nexus-redis redis-cli ping" \
	  "MinIO:curl -sf http://localhost:9000/minio/health/live" \
	  "Grafana:curl -sf http://localhost:3000/api/health" \
	  "Prometheus:curl -sf http://localhost:9090/-/healthy" \
	  "Loki:curl -sf http://localhost:3100/ready" \
	  "Tempo:curl -sf http://localhost:3200/ready" \
	  "Keycloak:curl -sf http://localhost:9990/health/ready" \
	  "MailHog:curl -sf http://localhost:8025" \
	  "Toxiproxy:curl -sf http://localhost:8474/version"; do \
	  NAME=$${check%%:*}; CMD=$${check#*:}; \
	  if eval "$$CMD" > /dev/null 2>&1; then \
	    echo "  ✅ $$NAME"; \
	  else \
	    echo "  ❌ $$NAME"; FAILED=$$((FAILED + 1)); \
	  fi; \
	done; \
	if [ $$FAILED -gt 0 ]; then echo "$$FAILED service(s) failing"; exit 1; fi

# ═══════════════════════════════════════════════════════════════
# HEALTH & DIAGNOSTICS
# ═══════════════════════════════════════════════════════════════
.PHONY: check-localstack-community
check-localstack-community: ## Verify LocalStack config doesn't require Pro license
	@# Extract only the localstack service block, then check for Pro-only triggers.
	@# Word boundaries in the SERVICES value prevent false positives (e.g., "sts"
	@# matching "secretsmanager").
	@TRIGGERS=$$(awk '/^  localstack:/{flag=1;next} flag && /^  [a-zA-Z]/{flag=0} flag' \
	    docker/docker-compose.yml 2>/dev/null | \
	  grep -E "PERSISTENCE:[[:space:]]*[1-9]|cognito-idp|(^|[\",])(rds|eks|ecs|glue|athena|redshift)([\",]|$$)" || true); \
	if [ -n "$$TRIGGERS" ]; then \
	  echo -e "$(RED)❌ Detected LocalStack Pro triggers:$(RESET)"; \
	  echo "$$TRIGGERS" | sed 's/^/    /'; \
	  exit 1; \
	else \
	  echo -e "$(GREEN)✅ Config compatible con LocalStack Community$(RESET)"; \
	fi

.PHONY: check-pinned-images
check-pinned-images: ## Verify all Docker images are pinned to specific versions
	@UNPINNED=$$(grep -E "^\s+image:.*:latest\s*$$" docker/docker-compose.yml || true); \
	if [ -n "$$UNPINNED" ]; then \
	  echo -e "$(RED)❌ Encontradas imágenes con :latest — pinnear a versión estable:$(RESET)"; \
	  echo "$$UNPINNED" | sed 's/^/    /'; \
	  exit 1; \
	else \
	  echo -e "$(GREEN)✅ Todas las imágenes están pinneadas$(RESET)"; \
	fi

.PHONY: check-preflight
check-preflight: check-localstack-community check-pinned-images ## Run all pre-flight checks

.PHONY: check-ports
check-ports: ## Check if lab ports are available on host (assumes lab is DOWN)
	@echo -e "$(BLUE)🔌 Checking port availability...$(RESET)"
	@# Detect if the lab is already running — this check only makes sense
	@# BEFORE 'lab-up' to catch conflicts with other software on the host.
	@if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^nexus-"; then \
	  echo -e "$(YELLOW)⚠️  Lab is currently running. This check is only useful BEFORE 'lab-up'.$(RESET)"; \
	  echo -e "$(YELLOW)   Run 'make lab-down' first if you want to test port availability.$(RESET)"; \
	  exit 0; \
	fi
	@BUSY=0; \
	for port in 3000 3100 3200 4317 4318 4566 5432 5433 6379 8025 8080 8474 8888 8889 9000 9001 9090 9095 9990 11434; do \
	  if ss -tln 2>/dev/null | grep -q ":$$port "; then \
	    echo -e "  Port $$port: $(RED)❌ in use$(RESET)"; \
	    BUSY=$$((BUSY + 1)); \
	  else \
	    echo -e "  Port $$port: $(GREEN)✅ available$(RESET)"; \
	  fi; \
	done; \
	if [ $$BUSY -gt 0 ]; then \
	  echo ""; \
	  echo -e "$(RED)$$BUSY port(s) already in use by other processes.$(RESET)"; \
	  echo -e "$(YELLOW)Free them before 'make lab-up' or you'll get 'bind: address already in use' errors.$(RESET)"; \
	  echo -e "$(YELLOW)Find owners with: sudo ss -tlnp$(RESET)"; \
	  exit 1; \
	fi

.PHONY: check-volumes
check-volumes: ## List all lab volumes and their sizes
	@echo -e "$(BLUE)📦 Lab volumes:$(RESET)"
	@docker volume ls | grep nexuscloud-lab || echo "  (no volumes yet)"
	@echo ""
	@echo -e "$(YELLOW)⚠️  If you downgraded a stateful image (postgres, minio, loki,$(RESET)"
	@echo -e "$(YELLOW)   tempo, prometheus, keycloak, redis), delete its volume before$(RESET)"
	@echo -e "$(YELLOW)   restarting to avoid schema/format incompatibilities:$(RESET)"
	@echo -e "     make reset-service SERVICE=<name>"

# ═══════════════════════════════════════════════════════════════
# RESET & CLEANUP
# ═══════════════════════════════════════════════════════════════
.PHONY: reset-stateful
reset-stateful: ## Nuclear reset — drops all stateful volumes and re-provisions
	@echo -e "$(RED)⚠️  This will DELETE all local state (databases, minio, keycloak, etc.)$(RESET)"
	@echo "Press Ctrl+C in 5 seconds to abort..."
	@sleep 5
	docker compose -f docker/docker-compose.yml down -v
	@docker volume ls | grep nexuscloud-lab | awk '{print $$2}' | xargs -r docker volume rm 2>/dev/null || true
	@echo -e "$(GREEN)✅ Volumes cleaned. Run 'make lab-up' to start fresh.$(RESET)"

.PHONY: reset-service
reset-service: ## Reset a single stateful service (usage: make reset-service SERVICE=keycloak)
	@if [ -z "$(SERVICE)" ]; then \
	  echo -e "$(RED)❌ Usage: make reset-service SERVICE=<name>$(RESET)"; \
	  echo -e "  Example: make reset-service SERVICE=keycloak"; \
	  echo -e "  Valid: localstack, postgres-primary, postgres-replica, minio,"; \
	  echo -e "         grafana, loki, tempo, prometheus, keycloak, ollama"; \
	  exit 1; \
	fi
	@echo -e "$(YELLOW)Resetting $(SERVICE)...$(RESET)"
	docker compose -f docker/docker-compose.yml stop $(SERVICE)
	docker compose -f docker/docker-compose.yml rm -f $(SERVICE)
	@docker volume rm nexuscloud-lab_$(shell echo $(SERVICE) | tr - _)_data 2>/dev/null || true
	docker compose -f docker/docker-compose.yml up -d $(SERVICE)
	@echo -e "$(GREEN)✅ $(SERVICE) reset complete$(RESET)"

# ═══════════════════════════════════════════════════════════════
# NUKE OPTION
# ═══════════════════════════════════════════════════════════════
.PHONY: destroy
destroy: lab-clean ## Destroy EVERYTHING (including data)
	@echo -e "$(RED)💥 Everything destroyed$(RESET)"
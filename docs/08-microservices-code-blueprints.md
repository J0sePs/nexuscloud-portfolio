# 08 · Microservices Code Blueprints

> **Objetivo:** proporcionar el código base (simple pero completo) de los 5 microservicios de NexusCloud. Cada uno sigue **clean architecture**, es dockerizable, testeable, y observable end-to-end.

---

## 🎯 1. Los 5 microservicios

| Service | Responsibility | Runtime | Owner |
|---|---|---|---|
| **api-gateway** | Ingress, JWT verify, routing, correlation IDs | FastAPI (kind Pod) | B-DEV + A-LEAD |
| **auth-service** | Issue/verify JWTs, Keycloak integration | FastAPI (kind Pod) | B-DEV + C-SEC |
| **payment-service** | Core: process payments, transactional outbox | FastAPI (kind Pod) | B-DEV |
| **notification-service** | Async worker: SQS consumer, sends emails | Python async worker | B-DEV |
| **ai-ops-agent** | Watches OTel exceptions, creates Jira tickets | Python daemon | B-DEV + A-LEAD |

---

## 🏛️ 2. Clean Architecture layout (aplied per service)

```
services/payment-service/
├── pyproject.toml
├── Dockerfile
├── README.md
└── src/payment_service/
    ├── __init__.py
    ├── main.py                    # FastAPI entrypoint (thin)
    ├── config.py                  # Pydantic Settings (env vars)
    │
    ├── api/                       # ← Inbound adapters (HTTP)
    │   ├── __init__.py
    │   ├── v1/
    │   │   ├── __init__.py
    │   │   ├── payments.py        # POST /v1/payments router
    │   │   └── schemas.py         # Pydantic request/response
    │   └── health.py              # /health/live, /health/ready
    │
    ├── application/               # ← Use cases
    │   ├── __init__.py
    │   ├── process_payment.py     # ProcessPayment use case
    │   ├── refund_payment.py
    │   └── ports.py               # Abstract interfaces
    │
    ├── domain/                    # ← Pure business logic (no I/O)
    │   ├── __init__.py
    │   ├── entities.py            # Payment entity, states
    │   ├── value_objects.py       # Money, TransactionId
    │   ├── events.py              # Domain events
    │   └── exceptions.py          # Domain exceptions
    │
    ├── infrastructure/            # ← Outbound adapters (I/O)
    │   ├── __init__.py
    │   ├── db/
    │   │   ├── __init__.py
    │   │   ├── models.py          # SQLAlchemy models
    │   │   ├── repositories.py    # PaymentRepository impl
    │   │   └── migrations/        # Alembic
    │   ├── messaging/
    │   │   ├── __init__.py
    │   │   ├── sqs_publisher.py   # SQS event publisher
    │   │   └── outbox_worker.py   # Poll outbox → publish
    │   └── external/
    │       ├── __init__.py
    │       └── bank_client.py     # Mock external bank API
    │
    ├── middleware/                # Cross-cutting concerns
    │   ├── __init__.py
    │   ├── correlation.py         # X-Correlation-ID
    │   ├── auth.py                # JWT verify (dependency)
    │   ├── rate_limit.py          # Redis sliding window
    │   └── error_handler.py       # Global exception handler
    │
    └── telemetry/                 # Observability setup
        ├── __init__.py
        ├── logging.py             # structlog config
        ├── tracing.py             # OpenTelemetry setup
        └── metrics.py             # Prometheus metrics
```

---

## 📦 3. Shared library — `services/shared/`

Utilities reused by all services (deps common: structlog, OTel, error types).

### 3.1 `services/shared/pyproject.toml`

```toml
[tool.poetry]
name = "nexuscloud-shared"
version = "0.1.0"
description = "Shared library for NexusCloud microservices"
authors = ["NexusCloud Team <team@nexuscloud.local>"]

[tool.poetry.dependencies]
python = "^3.12"
structlog = "^24.1.0"
opentelemetry-api = "^1.24.0"
opentelemetry-sdk = "^1.24.0"
opentelemetry-instrumentation-fastapi = "^0.45b0"
opentelemetry-instrumentation-asyncpg = "^0.45b0"
opentelemetry-exporter-otlp = "^1.24.0"
pydantic = "^2.7.0"
pydantic-settings = "^2.2.1"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### 3.2 `services/shared/src/nexuscloud_shared/logging.py`

```python
"""Structured logging setup shared across services."""
import logging
import sys
import structlog


def configure_logging(service_name: str, log_level: str = "INFO") -> None:
    """Configure structlog + stdlib logging for JSON structured output."""
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=getattr(logging, log_level.upper()),
    )
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.CallsiteParameterAdder(
                parameters={
                    structlog.processors.CallsiteParameter.MODULE,
                    structlog.processors.CallsiteParameter.FUNC_NAME,
                    structlog.processors.CallsiteParameter.LINENO,
                }
            ),
            structlog.processors.JSONRenderer(),
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
    logger = structlog.get_logger(service_name)
    logger.info("logging_configured", service=service_name, level=log_level)
```

### 3.3 `services/shared/src/nexuscloud_shared/telemetry.py`

```python
"""OpenTelemetry setup shared across services."""
import os
from opentelemetry import trace, metrics
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import (
    OTLPMetricExporter,
)
from opentelemetry.sdk.resources import Resource, SERVICE_NAME


def setup_telemetry(service_name: str) -> None:
    """Initialize OpenTelemetry tracing and metrics with OTLP exporter."""
    otel_endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-collector:4317")
    resource = Resource.create({SERVICE_NAME: service_name})

    # Tracing
    trace_provider = TracerProvider(resource=resource)
    trace_processor = BatchSpanProcessor(
        OTLPSpanExporter(endpoint=otel_endpoint, insecure=True)
    )
    trace_provider.add_span_processor(trace_processor)
    trace.set_tracer_provider(trace_provider)

    # Metrics
    metric_reader = PeriodicExportingMetricReader(
        OTLPMetricExporter(endpoint=otel_endpoint, insecure=True)
    )
    meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
    metrics.set_meter_provider(meter_provider)
```

### 3.4 `services/shared/src/nexuscloud_shared/llm_client.py`

```python
"""Pluggable LLM client abstraction (Ollama / Bedrock / Groq / Gemini)."""
from abc import ABC, abstractmethod
from typing import Protocol
import os
import httpx


class LLMClient(Protocol):
    """Interface for LLM providers used by AI-Ops agent."""

    async def generate_diagnosis(self, error_context: str) -> dict: ...


class OllamaClient:
    """Local Ollama LLM implementation (default for local dev)."""

    def __init__(self, base_url: str | None = None, model: str = "llama3.2:3b"):
        self.base_url = base_url or os.getenv("OLLAMA_URL", "http://ollama:11434")
        self.model = model

    async def generate_diagnosis(self, error_context: str) -> dict:
        prompt = f"""You are an SRE assistant. Analyze this error and produce
an ITIL v4 incident diagnosis. Return ONLY valid JSON with keys:
  - summary (one line)
  - severity (P1|P2|P3|P4)
  - root_cause (2-3 sentences)
  - remediation_plan (numbered list, 3-5 steps)

Error context:
{error_context}"""
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.model,
                    "prompt": prompt,
                    "format": "json",
                    "stream": False,
                },
            )
            response.raise_for_status()
            return response.json()


class BedrockClient:
    """AWS Bedrock implementation (documented, for cloud deploy)."""

    def __init__(self, model_id: str = "anthropic.claude-3-haiku-20240307-v1:0"):
        # Requires: pip install boto3
        # Implementation deferred; documented interface
        import boto3
        self.client = boto3.client("bedrock-runtime")
        self.model_id = model_id

    async def generate_diagnosis(self, error_context: str) -> dict:
        # ... implementation using boto3 ...
        raise NotImplementedError("Enable when running in AWS")


def get_llm_client() -> LLMClient:
    """Factory based on env config."""
    provider = os.getenv("LLM_PROVIDER", "ollama").lower()
    if provider == "ollama":
        return OllamaClient()
    if provider == "bedrock":
        return BedrockClient()
    raise ValueError(f"Unknown LLM_PROVIDER: {provider}")
```

---

## 💳 4. `payment-service` (main showcase)

### 4.1 `services/payment-service/pyproject.toml`

```toml
[tool.poetry]
name = "payment-service"
version = "0.1.0"

[tool.poetry.dependencies]
python = "^3.12"
fastapi = "^0.111.0"
uvicorn = {extras = ["standard"], version = "^0.30.0"}
pydantic = "^2.7.0"
pydantic-settings = "^2.2.1"
sqlalchemy = {extras = ["asyncio"], version = "^2.0.30"}
asyncpg = "^0.29.0"
alembic = "^1.13.1"
redis = "^5.0.4"
boto3 = "^1.34.100"
tenacity = "^8.3.0"
nexuscloud-shared = {path = "../shared", develop = true}

[tool.poetry.group.dev.dependencies]
pytest = "^8.2.0"
pytest-asyncio = "^0.23.6"
pytest-cov = "^5.0.0"
httpx = "^0.27.0"
testcontainers = "^4.4.0"

[tool.pytest.ini_options]
asyncio_mode = "auto"
addopts = "--cov=src/payment_service --cov-report=term-missing"

[tool.ruff]
line-length = 100
target-version = "py312"
```

### 4.2 `services/payment-service/src/payment_service/config.py`

```python
"""Application configuration via env vars (Pydantic Settings)."""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """All config comes from environment variables (12-Factor)."""

    model_config = SettingsConfigDict(env_prefix="PAYMENT_", env_file=".env")

    # Service
    service_name: str = "payment-service"
    log_level: str = "INFO"
    environment: str = "local"

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 4

    # Database
    db_host: str = "postgres-primary"
    db_port: int = 5432
    db_name: str = "payments"
    db_user: str = "nexus"
    db_password: str = "change_me"
    db_pool_size: int = 10
    db_max_overflow: int = 20
    db_pool_timeout: int = 30

    @property
    def db_url(self) -> str:
        return (
            f"postgresql+asyncpg://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )

    # Redis
    redis_url: str = "redis://redis:6379/0"

    # AWS / LocalStack
    aws_endpoint_url: str = "http://localstack:4566"
    aws_region: str = "us-east-1"
    sqs_queue_url: str = "http://localstack:4566/000000000000/payment-processing-queue"

    # Auth
    jwt_public_key_url: str = "http://keycloak:8080/realms/nexuscloud/protocol/openid-connect/certs"

    # Rate limiting
    rate_limit_per_minute: int = 100

    # Business rules
    max_transaction_amount: float = 100_000.00


settings = Settings()
```

### 4.3 `services/payment-service/src/payment_service/domain/entities.py`

```python
"""Domain entities — pure business logic, no I/O."""
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from uuid import UUID, uuid4


class PaymentState(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"


@dataclass
class Payment:
    """Payment aggregate root."""
    transaction_id: str
    account_id: str
    amount: float
    currency: str
    state: PaymentState = PaymentState.PENDING
    id: UUID = field(default_factory=uuid4)
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    failure_reason: str | None = None

    def mark_processing(self) -> None:
        if self.state != PaymentState.PENDING:
            raise ValueError(f"Cannot process payment in state {self.state}")
        self.state = PaymentState.PROCESSING
        self.updated_at = datetime.now(timezone.utc)

    def mark_completed(self) -> None:
        if self.state != PaymentState.PROCESSING:
            raise ValueError(f"Cannot complete payment in state {self.state}")
        self.state = PaymentState.COMPLETED
        self.updated_at = datetime.now(timezone.utc)

    def mark_failed(self, reason: str) -> None:
        self.state = PaymentState.FAILED
        self.failure_reason = reason
        self.updated_at = datetime.now(timezone.utc)
```

### 4.4 `services/payment-service/src/payment_service/domain/exceptions.py`

```python
"""Domain-level exceptions."""


class DomainError(Exception):
    """Base for domain errors."""


class PaymentValidationError(DomainError):
    """Payment failed business rule validation."""


class DuplicateTransactionError(DomainError):
    """Idempotency violation."""


class AmountExceedsLimitError(PaymentValidationError):
    """Amount above configured threshold."""
```

### 4.5 `services/payment-service/src/payment_service/application/ports.py`

```python
"""Abstract interfaces (ports) for infrastructure implementations."""
from abc import ABC, abstractmethod
from payment_service.domain.entities import Payment


class PaymentRepositoryPort(ABC):
    """Persistence contract for Payment aggregate."""

    @abstractmethod
    async def save(self, payment: Payment) -> None: ...

    @abstractmethod
    async def find_by_transaction_id(self, tx_id: str) -> Payment | None: ...


class EventPublisherPort(ABC):
    """Contract for publishing domain events."""

    @abstractmethod
    async def publish(self, event_type: str, payload: dict) -> None: ...


class IdempotencyStorePort(ABC):
    """Contract for idempotency key storage (Redis-backed)."""

    @abstractmethod
    async def is_duplicate(self, key: str) -> bool: ...

    @abstractmethod
    async def mark_processed(self, key: str, ttl_seconds: int = 86400) -> None: ...
```

### 4.6 `services/payment-service/src/payment_service/application/process_payment.py`

```python
"""ProcessPayment use case — application service."""
from dataclasses import dataclass
import structlog
from opentelemetry import trace
from payment_service.domain.entities import Payment, PaymentState
from payment_service.domain.exceptions import (
    AmountExceedsLimitError,
    DuplicateTransactionError,
)
from payment_service.application.ports import (
    PaymentRepositoryPort,
    EventPublisherPort,
    IdempotencyStorePort,
)
from payment_service.config import settings

logger = structlog.get_logger()
tracer = trace.get_tracer(__name__)


@dataclass
class ProcessPaymentCommand:
    """Input DTO for the use case."""
    transaction_id: str
    account_id: str
    amount: float
    currency: str = "USD"


@dataclass
class ProcessPaymentResult:
    """Output DTO."""
    payment_id: str
    state: PaymentState
    correlation_id: str


class ProcessPaymentUseCase:
    """Orchestrates the process_payment business flow."""

    def __init__(
        self,
        repo: PaymentRepositoryPort,
        events: EventPublisherPort,
        idempotency: IdempotencyStorePort,
    ):
        self.repo = repo
        self.events = events
        self.idempotency = idempotency

    async def execute(
        self, cmd: ProcessPaymentCommand, correlation_id: str
    ) -> ProcessPaymentResult:
        with tracer.start_as_current_span("process_payment") as span:
            span.set_attribute("payment.transaction_id", cmd.transaction_id)
            span.set_attribute("payment.amount", cmd.amount)

            log = logger.bind(
                transaction_id=cmd.transaction_id,
                correlation_id=correlation_id,
                amount=cmd.amount,
            )
            log.info("process_payment_started")

            # 1. Business rule validation
            if cmd.amount > settings.max_transaction_amount:
                log.warning("amount_exceeds_limit")
                raise AmountExceedsLimitError(
                    f"Amount {cmd.amount} exceeds limit {settings.max_transaction_amount}"
                )

            # 2. Idempotency check
            if await self.idempotency.is_duplicate(cmd.transaction_id):
                log.warning("duplicate_transaction")
                existing = await self.repo.find_by_transaction_id(cmd.transaction_id)
                if existing:
                    return ProcessPaymentResult(
                        payment_id=str(existing.id),
                        state=existing.state,
                        correlation_id=correlation_id,
                    )
                raise DuplicateTransactionError(cmd.transaction_id)

            # 3. Create and persist
            payment = Payment(
                transaction_id=cmd.transaction_id,
                account_id=cmd.account_id,
                amount=cmd.amount,
                currency=cmd.currency,
            )
            await self.repo.save(payment)
            await self.idempotency.mark_processed(cmd.transaction_id)

            # 4. Publish domain event (transactional outbox)
            await self.events.publish(
                "payment.pending",
                {
                    "payment_id": str(payment.id),
                    "transaction_id": payment.transaction_id,
                    "amount": payment.amount,
                    "correlation_id": correlation_id,
                },
            )

            log.info("process_payment_completed", payment_id=str(payment.id))
            return ProcessPaymentResult(
                payment_id=str(payment.id),
                state=payment.state,
                correlation_id=correlation_id,
            )
```

### 4.7 `services/payment-service/src/payment_service/api/v1/schemas.py`

```python
"""HTTP request/response schemas (Pydantic v2)."""
from decimal import Decimal
from pydantic import BaseModel, Field, field_validator


class PaymentRequest(BaseModel):
    """POST /v1/payments request body."""
    transaction_id: str = Field(..., min_length=8, max_length=64, examples=["TX-99021"])
    account_id: str = Field(..., min_length=4, max_length=64, examples=["ACC-4021"])
    amount: float = Field(..., gt=0, examples=[250.00])
    currency: str = Field(default="USD", pattern="^[A-Z]{3}$")

    @field_validator("transaction_id")
    @classmethod
    def no_sql_meta(cls, v: str) -> str:
        forbidden = ["'", '"', ";", "--", "/*", "*/", "\\"]
        if any(c in v for c in forbidden):
            raise ValueError("transaction_id contains forbidden characters")
        return v


class PaymentResponse(BaseModel):
    """POST /v1/payments 202 response body."""
    payment_id: str
    state: str
    correlation_id: str
    message: str = "Payment accepted for async processing"


class ErrorResponse(BaseModel):
    error_code: str
    message: str
    correlation_id: str
```

### 4.8 `services/payment-service/src/payment_service/api/v1/payments.py`

```python
"""HTTP router for /v1/payments."""
from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, Request, status
import structlog
from payment_service.api.v1.schemas import (
    PaymentRequest,
    PaymentResponse,
    ErrorResponse,
)
from payment_service.application.process_payment import (
    ProcessPaymentUseCase,
    ProcessPaymentCommand,
)
from payment_service.domain.exceptions import (
    AmountExceedsLimitError,
    DuplicateTransactionError,
)
from payment_service.middleware.auth import require_jwt
from payment_service.middleware.rate_limit import rate_limit

logger = structlog.get_logger()
router = APIRouter(prefix="/v1/payments", tags=["payments"])


def get_process_payment_use_case() -> ProcessPaymentUseCase:
    """DI wiring — real implementation registered in main.py."""
    raise NotImplementedError  # Overridden via app.dependency_overrides


@router.post(
    "",
    status_code=status.HTTP_202_ACCEPTED,
    response_model=PaymentResponse,
    responses={
        400: {"model": ErrorResponse},
        401: {"model": ErrorResponse},
        409: {"model": ErrorResponse},
        429: {"model": ErrorResponse},
    },
)
async def create_payment(
    request: Request,
    payment: PaymentRequest,
    use_case: ProcessPaymentUseCase = Depends(get_process_payment_use_case),
    _rl: None = Depends(rate_limit),
    _auth: dict = Depends(require_jwt),
) -> PaymentResponse:
    """Process a payment asynchronously (returns 202 after enqueue)."""
    correlation_id = request.headers.get("X-Correlation-ID") or str(uuid4())
    cmd = ProcessPaymentCommand(**payment.model_dump())
    try:
        result = await use_case.execute(cmd, correlation_id)
    except AmountExceedsLimitError as e:
        raise HTTPException(
            status_code=400,
            detail=ErrorResponse(
                error_code="AMOUNT_EXCEEDS_LIMIT",
                message=str(e),
                correlation_id=correlation_id,
            ).model_dump(),
        )
    except DuplicateTransactionError as e:
        raise HTTPException(
            status_code=409,
            detail=ErrorResponse(
                error_code="DUPLICATE_TRANSACTION",
                message=str(e),
                correlation_id=correlation_id,
            ).model_dump(),
        )
    return PaymentResponse(
        payment_id=result.payment_id,
        state=result.state.value,
        correlation_id=correlation_id,
    )
```

### 4.9 `services/payment-service/src/payment_service/main.py`

```python
"""FastAPI application entrypoint."""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from nexuscloud_shared.logging import configure_logging
from nexuscloud_shared.telemetry import setup_telemetry
from payment_service.config import settings
from payment_service.api.v1 import payments as payments_router
from payment_service.api import health as health_router
from payment_service.middleware.correlation import CorrelationIdMiddleware
from payment_service.middleware.error_handler import register_exception_handlers


@asynccontextmanager
async def lifespan(app: FastAPI):
    configure_logging(service_name=settings.service_name, log_level=settings.log_level)
    setup_telemetry(service_name=settings.service_name)
    # Initialize DB pool, Redis client, etc.
    yield
    # Cleanup


def create_app() -> FastAPI:
    app = FastAPI(
        title="NexusCloud Payment Service",
        version="1.0.0",
        lifespan=lifespan,
        openapi_url="/api/openapi.json",
    )
    app.add_middleware(CorrelationIdMiddleware)
    app.include_router(health_router.router)
    app.include_router(payments_router.router)
    register_exception_handlers(app)
    FastAPIInstrumentor.instrument_app(app)
    return app


app = create_app()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "payment_service.main:app",
        host=settings.host,
        port=settings.port,
        reload=False,
    )
```

### 4.10 `services/payment-service/src/payment_service/api/health.py`

```python
"""Kubernetes liveness/readiness probes."""
from fastapi import APIRouter, HTTPException, status

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/live")
async def liveness() -> dict:
    """Fast: is the process alive?"""
    return {"status": "ok"}


@router.get("/ready")
async def readiness() -> dict:
    """Deep: are dependencies reachable?
    Checks DB and Redis before returning 200."""
    # TODO: implement real checks
    # For now:
    return {"status": "ok", "checks": {"db": "ok", "redis": "ok"}}
```

### 4.11 `services/payment-service/src/payment_service/middleware/correlation.py`

```python
"""Correlation ID middleware — propagates X-Correlation-ID end-to-end."""
from uuid import uuid4
import structlog
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    HEADER = "X-Correlation-ID"

    async def dispatch(self, request: Request, call_next):
        correlation_id = request.headers.get(self.HEADER) or str(uuid4())
        structlog.contextvars.bind_contextvars(correlation_id=correlation_id)
        response = await call_next(request)
        response.headers[self.HEADER] = correlation_id
        structlog.contextvars.clear_contextvars()
        return response
```

### 4.12 `services/payment-service/Dockerfile`

```dockerfile
# ═════════════════════════════════════════════════════════════════════════
# Stage 1: builder — install dependencies
# ═════════════════════════════════════════════════════════════════════════
FROM python:3.12-slim-bookworm AS builder

WORKDIR /build

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Poetry
RUN pip install --no-cache-dir poetry==1.8.2 \
    && poetry config virtualenvs.create false

# Copy dependency manifest first (cache-friendly)
COPY services/shared/pyproject.toml services/shared/poetry.lock ./shared/
COPY services/payment-service/pyproject.toml services/payment-service/poetry.lock ./payment-service/

WORKDIR /build/payment-service
COPY services/shared /build/shared

RUN poetry install --without dev --no-interaction --no-ansi --no-root

COPY services/payment-service/src ./src
RUN poetry install --without dev --no-interaction --no-ansi

# ═════════════════════════════════════════════════════════════════════════
# Stage 2: runtime — distroless, non-root, minimal
# ═════════════════════════════════════════════════════════════════════════
FROM gcr.io/distroless/python3-debian12:nonroot

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /build/payment-service/src /app/src

ENV PYTHONPATH=/app/src \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

EXPOSE 8000

USER nonroot:nonroot

CMD ["-m", "uvicorn", "payment_service.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 4.13 `services/payment-service/tests/unit/test_process_payment.py`

```python
"""Unit tests for ProcessPayment use case (pure, no I/O)."""
import pytest
from unittest.mock import AsyncMock
from payment_service.application.process_payment import (
    ProcessPaymentUseCase,
    ProcessPaymentCommand,
)
from payment_service.domain.entities import PaymentState
from payment_service.domain.exceptions import (
    AmountExceedsLimitError,
    DuplicateTransactionError,
)


@pytest.fixture
def use_case():
    return ProcessPaymentUseCase(
        repo=AsyncMock(),
        events=AsyncMock(),
        idempotency=AsyncMock(),
    )


async def test_happy_path(use_case: ProcessPaymentUseCase):
    use_case.idempotency.is_duplicate.return_value = False
    cmd = ProcessPaymentCommand(
        transaction_id="TX-001",
        account_id="ACC-001",
        amount=100.0,
    )
    result = await use_case.execute(cmd, correlation_id="corr-1")
    assert result.state == PaymentState.PENDING
    use_case.repo.save.assert_awaited_once()
    use_case.events.publish.assert_awaited_once()


async def test_amount_exceeds_limit(use_case: ProcessPaymentUseCase):
    cmd = ProcessPaymentCommand(
        transaction_id="TX-002",
        account_id="ACC-001",
        amount=999_999_999,
    )
    with pytest.raises(AmountExceedsLimitError):
        await use_case.execute(cmd, correlation_id="corr-1")


async def test_duplicate_returns_existing(use_case: ProcessPaymentUseCase):
    use_case.idempotency.is_duplicate.return_value = True
    from payment_service.domain.entities import Payment
    existing = Payment(
        transaction_id="TX-003",
        account_id="ACC-001",
        amount=50.0,
        currency="USD",
        state=PaymentState.COMPLETED,
    )
    use_case.repo.find_by_transaction_id.return_value = existing
    cmd = ProcessPaymentCommand(
        transaction_id="TX-003",
        account_id="ACC-001",
        amount=50.0,
    )
    result = await use_case.execute(cmd, correlation_id="corr-1")
    assert result.state == PaymentState.COMPLETED
    use_case.repo.save.assert_not_awaited()
```

---

## 🤖 5. `ai-ops-agent` (highlight of your portfolio)

Este servicio impresiona porque **combina observability + LLMs + ITIL v4** — un stack que muy pocos candidatos junior tienen.

### 5.1 `services/ai-ops-agent/src/ai_ops_agent/main.py`

```python
"""AI-Ops agent: watches OTel exceptions, generates diagnosis via LLM,
creates ITIL v4 incident tickets in Jira."""
import asyncio
import json
import os
from datetime import datetime
import structlog
from nexuscloud_shared.logging import configure_logging
from nexuscloud_shared.llm_client import get_llm_client
from ai_ops_agent.jira_client import JiraClient
from ai_ops_agent.otel_watcher import OtelWatcher

configure_logging(service_name="ai-ops-agent")
logger = structlog.get_logger()


async def process_exception(exception_event: dict, llm, jira) -> None:
    """One iteration of the agent loop."""
    log = logger.bind(
        service=exception_event.get("service"),
        exception=exception_event.get("exception_type"),
        correlation_id=exception_event.get("correlation_id"),
    )
    log.info("processing_exception")

    context = json.dumps(exception_event, indent=2)

    try:
        diagnosis_raw = await llm.generate_diagnosis(context)
        diagnosis = json.loads(diagnosis_raw.get("response", "{}"))
    except Exception as e:
        log.error("llm_diagnosis_failed", error=str(e))
        return

    ticket_key = await jira.create_incident(
        summary=diagnosis.get("summary", "AI-Ops: Unclassified Incident"),
        severity=diagnosis.get("severity", "P3"),
        root_cause=diagnosis.get("root_cause", "Investigation required"),
        remediation=diagnosis.get("remediation_plan", []),
        raw_context=context,
        correlation_id=exception_event.get("correlation_id"),
    )
    log.info("jira_ticket_created", ticket_key=ticket_key)


async def main() -> None:
    logger.info("ai_ops_agent_starting")
    llm = get_llm_client()
    jira = JiraClient(
        url=os.getenv("JIRA_URL", "https://nexuscloud.atlassian.net"),
        user=os.getenv("JIRA_USER", "you@example.com"),
        api_token=os.getenv("JIRA_API_TOKEN", "mock"),
        project_key=os.getenv("JIRA_PROJECT_KEY", "NEX"),
    )
    watcher = OtelWatcher()

    async for exception_event in watcher.stream():
        await process_exception(exception_event, llm, jira)


if __name__ == "__main__":
    asyncio.run(main())
```

### 5.2 `services/ai-ops-agent/src/ai_ops_agent/jira_client.py`

```python
"""Jira Cloud REST API v3 client for incident ticket creation."""
import httpx
import structlog

logger = structlog.get_logger()


class JiraClient:
    def __init__(self, url: str, user: str, api_token: str, project_key: str):
        self.url = url.rstrip("/")
        self.auth = (user, api_token)
        self.project_key = project_key
        self.mock_mode = api_token == "mock"

    async def create_incident(
        self,
        summary: str,
        severity: str,
        root_cause: str,
        remediation: list,
        raw_context: str,
        correlation_id: str | None = None,
    ) -> str:
        if self.mock_mode:
            fake_key = f"{self.project_key}-{hash(summary) % 10000}"
            logger.info("jira_mock", ticket=fake_key, summary=summary)
            return fake_key

        remediation_text = "\n".join(f"- {step}" for step in remediation)
        description_adf = {
            "type": "doc",
            "version": 1,
            "content": [
                {"type": "paragraph", "content": [
                    {"type": "text", "text": f"**Severity:** {severity}\n"}]},
                {"type": "paragraph", "content": [
                    {"type": "text", "text": f"**Root Cause:**\n{root_cause}\n"}]},
                {"type": "paragraph", "content": [
                    {"type": "text", "text": f"**Remediation:**\n{remediation_text}\n"}]},
                {"type": "codeBlock", "attrs": {"language": "json"},
                 "content": [{"type": "text", "text": raw_context}]},
            ],
        }

        payload = {
            "fields": {
                "project": {"key": self.project_key},
                "summary": f"[AI-Ops] {summary}",
                "description": description_adf,
                "issuetype": {"name": "Task"},
                "labels": ["itil-incident", "source-ai-ops-agent", f"priority-{severity}"],
            }
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{self.url}/rest/api/3/issue",
                json=payload,
                auth=self.auth,
                headers={"Accept": "application/json"},
            )
            resp.raise_for_status()
            key = resp.json()["key"]
            logger.info("jira_ticket_created", ticket=key)
            return key
```

---

## 📄 6. `pre-commit` config (`.pre-commit-config.yaml`)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.4
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests, pydantic]

  - repo: https://github.com/pycqa/bandit
    rev: 1.7.8
    hooks:
      - id: bandit
        args: ["-c", "pyproject.toml"]

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.2
    hooks:
      - id: gitleaks

  - repo: https://github.com/bridgecrewio/checkov.git
    rev: 3.2.85
    hooks:
      - id: checkov
        args: [--soft-fail]
```

---

## 🔗 7. Cross-references

- Environment/deps: `07-local-lab-setup.md`
- Sprints where each service is built: `05-project-structure-and-timeline.md`
- Skills demonstrated by this code: `02-technical-skills-matrix.md`
- Team ownership per service: `03-github-workflow-and-team.md`

---

*Microservices Code Blueprints · v1.0*

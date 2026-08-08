# Infrastructure as Code

Manages all NexusCloud infrastructure with [OpenTofu](https://opentofu.org)
(see [ADR-0002](../docs/adr/0002-opentofu-vs-terraform.md)).

## Layout

```text
infra/
├── environments/          ← One directory per deployable environment
│   ├── dev/               ← Local development (LocalStack)
│   ├── prod/              ← Production (us-east-1)
│   └── dr/                ← Disaster recovery (us-west-2)
└── modules/               ← Reusable, versioned modules
    ├── networking/        ← VPC, subnets, NAT, SGs
    ├── security-baseline/ ← IAM baseline, KMS, GuardDuty, SecHub
    ├── eks/               ← EKS Auto Mode cluster
    ├── data-layer/        ← Aurora, DynamoDB, ElastiCache
    ├── messaging/         ← SQS, SNS, EventBridge
    └── observability/     ← Managed Prometheus, Managed Grafana
```

## Usage

```bash
# First-time: bootstrap the state backend
./scripts/infra/bootstrap-backend.sh dev

# Then: initialize and apply
cd infra/environments/dev
tflocal init
tflocal plan
tflocal apply
```

For real AWS deployment (Sprint 12), replace `tflocal` with `tofu` and
configure AWS credentials.

## LocalStack Community limitations

The `dev` environment targets LocalStack Community, which has partial
support for some AWS features:

- VPC Gateway endpoints (S3, DynamoDB): may return `NotImplemented`
  in some versions → **disabled by default in `dev`**, enabled in `prod`
- NAT Gateway: created but doesn't perform real NAT (mock behavior)
- Encryption/PublicAccessBlock APIs on S3: partially supported

All resources work correctly against AWS real; the module is designed
to be portable across both.

## Conventions

- All modules follow the standard structure: `variables.tf → main.tf → outputs.tf → README.md`
- Never hardcode values in modules — expose via variables with sane defaults
- Every resource has explicit tags (Environment, Project, Owner, ManagedBy)
- CIDR ranges live in `variables.tf` with clear defaults, never in `main.tf`

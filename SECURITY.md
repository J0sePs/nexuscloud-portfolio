# Security Policy

## Reporting a vulnerability

If you find a security issue in this project, please email the maintainer
directly (see profile) instead of opening a public issue. We aim to
respond within 72 hours.

## Supported versions

Only the `main` branch is actively maintained.

## Security practices

- All commits scanned with `gitleaks` (pre-commit)
- Dependencies scanned with `pip-audit` and `trivy`
- IaC scanned with `checkov` and `tfsec`
- Container images scanned with `trivy`
- SBOM generated with `syft` on releases

# ADR-0002: Use OpenTofu as the primary IaC engine

- **Status:** Accepted
- **Date:** 2026-08-07
- **Deciders:** A-LEAD, D-OPS
- **Tags:** iac, tooling, licensing, supply-chain

## Context and Problem Statement

NexusCloud requires an Infrastructure-as-Code (IaC) engine to manage AWS
resources declaratively. The dominant tool for years was HashiCorp Terraform.
However, significant events between 2023 and 2026 have reshaped the landscape:

- **August 2023**: HashiCorp changed Terraform's license from MPL 2.0 to
  Business Source License (BSL). This is a **source-available**, not
  open-source license — commercial competitors are forbidden.
- **September 2023**: The community forked Terraform as **OpenTofu**,
  under a Linux Foundation umbrella.
- **April 2024**: OpenTofu released v1.6, feature-parity with Terraform 1.5.
- **February 2025**: IBM completes acquisition of HashiCorp for $6.4B.
  Terraform becomes an IBM product.
- **March 2026**: HashiCorp Cloud Platform (HCP) Terraform ends its free tier;
  managed backend now paid.
- **June 2026**: OpenTofu becomes a CNCF Incubating project.

For a portfolio project that will be built in 2026 and referenced in job
applications through 2028+, choosing an IaC engine means placing a bet on
which ecosystem will dominate for the medium term.

## Decision Drivers

- **License risk**: BSL restricts what we can do with the code; MPL 2.0
  does not
- **Longevity**: Which tool is more likely to be actively maintained
  in 2028?
- **Ecosystem compatibility**: Which tool has broader provider and module
  support?
- **Cost**: Managed backends and CI runners should be $0 for a portfolio
  project
- **Job market signaling**: Which choice looks more forward-looking to a
  reviewer in 2027?
- **Migration effort if we're wrong**: How reversible is the decision?

## Considered Options

1. **Terraform (IBM/HashiCorp)** — Historical incumbent, BSL license
2. **OpenTofu (Linux Foundation)** — Community fork, MPL 2.0 license
3. **Pulumi** — Programmatic IaC in TypeScript/Python/Go
4. **AWS CDK** — AWS-native, TypeScript/Python programmatic
5. **CloudFormation** — AWS-native, YAML declarative

## Decision Outcome

Chosen option: **OpenTofu**, because it satisfies all decision drivers
simultaneously:

- **License**: MPL 2.0 is true open source; no vendor lock-in risk
- **Longevity**: CNCF backing signals long-term stewardship. Adopters in
  production (2026) include Boeing, Capital One, AMD, ByteDance
- **Compatibility**: OpenTofu is a **drop-in replacement** — same HCL,
  same providers, same state file format. Migration is `mv .terraform.lock.hcl` +
  replacing the CLI binary
- **Cost**: Fully free. Backend can be self-hosted (S3 + DynamoDB) or
  use free-tier alternatives
- **Job signaling**: Mentioning OpenTofu in a 2027 CV signals awareness
  of the ecosystem shift; mentioning only Terraform signals staleness
- **Reversibility**: If OpenTofu stalls, we can revert to Terraform
  with near-zero effort

In the CV we will write "**OpenTofu / Terraform**" to cover both.

### Consequences

**Positive:**
- Zero licensing risk for any use case (including hypothetical commercial
  fork in the future)
- Access to OpenTofu-exclusive features shipping in v1.8+: native state
  encryption, `-exclude` flag, early variable evaluation
- Alignment with CNCF ecosystem (Kubernetes, ArgoCD, Prometheus)

**Negative:**
- Some tutorials and blog posts still assume Terraform CLI — minor mental
  translation needed
- HashiCorp-published modules on the Terraform Registry may not receive
  OpenTofu-specific optimizations
- Slightly smaller community (though growing fast: 300%+ YoY downloads)

**Neutral:**
- The HCL syntax is identical, so code samples from either community work
- CI/CD tooling (`gh-action-setup-tofu`, `setup-terraform`) exists for both

## Pros and Cons of the Options

### Option 1 — Terraform (IBM/HashiCorp)
- ✅ Pro: Largest ecosystem (2015-2023), most tutorials
- ✅ Pro: Managed HCP Terraform backend (paid since 2026)
- ❌ Con: BSL license restricts commercial derivative use
- ❌ Con: IBM ownership introduces enterprise-product roadmap risk
- ❌ Con: HCP free tier eliminated in March 2026

### Option 2 — OpenTofu ✓
- ✅ Pro: MPL 2.0 (true open source)
- ✅ Pro: CNCF Incubating (2026)
- ✅ Pro: Drop-in compatibility with Terraform 1.5 code
- ✅ Pro: Growing enterprise adoption (Boeing, Capital One, AMD)
- ✅ Pro: Native state encryption, `-exclude`, other v1.8+ features
- ❌ Con: Smaller community than Terraform (yet)
- ❌ Con: Some 3rd party providers slower to certify against OpenTofu

### Option 3 — Pulumi
- ✅ Pro: Real programming languages (TypeScript, Python, Go)
- ✅ Pro: Excellent testing story via language-native test frameworks
- ❌ Con: Different mental model (imperative underneath declarative)
- ❌ Con: Smaller ecosystem than Terraform/OpenTofu
- ❌ Con: Not what most AWS/DevOps job postings ask for (yet)

### Option 4 — AWS CDK
- ✅ Pro: First-party AWS support, best AWS service integration
- ❌ Con: AWS-only — no support for hybrid stacks
- ❌ Con: Generates CloudFormation under the hood (heavier state model)
- ❌ Con: Ties portfolio to a single cloud

### Option 5 — CloudFormation
- ✅ Pro: Fully managed by AWS, zero setup
- ❌ Con: YAML is verbose and error-prone at scale
- ❌ Con: AWS-only
- ❌ Con: Slower feature parity than OpenTofu/Terraform

## More Information

- Related ADRs:
  - [ADR-0001](./0001-record-architecture-decisions.md) — Adopting ADRs
- External references:
  - OpenTofu website: https://opentofu.org
  - CNCF project page: https://www.cncf.io/projects/opentofu/
  - IBM acquisition of HashiCorp: https://www.ibm.com/investor/press-release/ibm-completes-hashicorp-acquisition (Feb 2025)
  - HCP Terraform pricing changes: https://www.hashicorp.com/blog/hcp-terraform-pricing-2026
- Follow-up work:
  - Sprint 02: Write `infra/modules/networking` in OpenTofu HCL
  - Sprint 08: Enable OpenTofu state encryption

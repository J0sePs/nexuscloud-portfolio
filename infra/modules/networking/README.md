# Networking Module

Reusable OpenTofu module that provisions a production-grade VPC layout:
3-tier subnet architecture (public / private / isolated) across N Availability
Zones, NAT Gateway(s), Internet Gateway, route tables, optional VPC endpoints
for S3 and DynamoDB, and a baseline VPC-internal security group.

## Usage

```hcl
   module "networking" {
     source = "../../modules/networking"

     environment          = "dev"
     vpc_cidr             = "10.0.0.0/16"
     availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
     enable_nat_gateway   = true
     single_nat_gateway   = true   # Cost optimization for dev
     enable_vpc_endpoints = false  # Disable for LocalStack Community; true for AWS real
   }
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| environment | string | (required) | Environment name |
| vpc_cidr | string | 10.0.0.0/16 | VPC CIDR block |
| availability_zones | list | 3 AZs in us-east-1 | AZs |
| public_subnet_cidrs | list | .../24 x 3 | Public tier CIDRs |
| private_subnet_cidrs | list | .../24 x 3 | Private tier CIDRs |
| isolated_subnet_cidrs | list | .../24 x 3 | Isolated tier CIDRs |
| enable_nat_gateway | bool | true | Provision NAT? |
| single_nat_gateway | bool | true | Single vs per-AZ NAT |
| enable_vpc_endpoints | bool | false | S3/DDB Gateway endpoints (LocalStack Community: false) |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| isolated_subnet_ids | List of isolated subnet IDs |
| nat_gateway_ips | Public IPs of NAT (for allowlisting) |
| vpc_internal_security_group_id | Baseline SG |

## Design Notes

Aligned with AWS Well-Architected Security pillar:
- Databases in isolated subnets (no internet egress)
- Compute in private subnets (egress via NAT only)
- Load balancers only in public subnets
- Baseline SG defaults to VPC-internal only

## LocalStack Community caveats

- `enable_vpc_endpoints` disabled by default (LocalStack Community 3.8.x
  has partial VPC endpoint support)
- NAT Gateway is created but doesn't perform real NAT (mock)
- All resources are valid AWS API objects and portable to AWS real

# ═══════════════════════════════════════════════════════════
# Provider and version constraints
# ═══════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # Remote state backend — S3 bucket + DynamoDB lock table
  # Created by scripts/infra/bootstrap-backend.sh
  backend "s3" {
    bucket         = "nexuscloud-tfstate-dev"
    key            = "networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nexuscloud-tflock-dev"
    encrypt        = true
  }
}

# ═══════════════════════════════════════════════════════════
# AWS provider — primary region
# When using tflocal, credentials and endpoints are injected
# via environment variables automatically.
# ═══════════════════════════════════════════════════════════

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "nexuscloud"
      ManagedBy   = "opentofu"
      Owner       = "A-LEAD"
      Repository  = "nexuscloud-portfolio"
    }
  }
}

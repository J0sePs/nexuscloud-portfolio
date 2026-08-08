#!/usr/bin/env bash
# bootstrap-backend.sh — Create S3 bucket and DynamoDB table for OpenTofu remote state
#
# Usage: ./bootstrap-backend.sh [environment]
# Default environment: dev
#
# This must run BEFORE `tofu init` because the backend needs to exist.
# The script is idempotent: safe to run multiple times.

set -euo pipefail

ENVIRONMENT="${1:-dev}"
PROJECT="nexuscloud"
BUCKET_NAME="${PROJECT}-tfstate-${ENVIRONMENT}"
TABLE_NAME="${PROJECT}-tflock-${ENVIRONMENT}"
REGION="us-east-1"

# ─────────────────────────────────────────────────────────
# Verify prerequisites
# ─────────────────────────────────────────────────────────
if ! command -v awslocal &> /dev/null; then
  echo "❌ awslocal is not installed. Install with: pipx install awscli-local"
  exit 1
fi

if ! curl -sf http://localhost:4566/_localstack/health &> /dev/null; then
  echo "❌ LocalStack is not reachable at localhost:4566. Run 'make lab-up' first."
  exit 1
fi

echo "═══════════════════════════════════════════════════════════"
echo "🏗️  Bootstrapping OpenTofu backend for environment: $ENVIRONMENT"
echo "═══════════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# S3 bucket for state files
# ─────────────────────────────────────────────────────────
if awslocal s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "✅ Bucket $BUCKET_NAME already exists"
else
  echo "→ Creating bucket: $BUCKET_NAME"
  awslocal s3 mb "s3://$BUCKET_NAME" --region "$REGION"

  echo "→ Enabling versioning"
  awslocal s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

  echo "→ Enabling server-side encryption (AES256)"
  awslocal s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }' 2>/dev/null || echo "  (encryption API may be limited in LocalStack Community, continuing)"

  echo "→ Blocking all public access"
  awslocal s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
      "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
      2>/dev/null || echo "  (public-access-block may be limited in LocalStack Community, continuing)"

  echo "✅ Bucket $BUCKET_NAME created"
fi

# ─────────────────────────────────────────────────────────
# DynamoDB table for state locking
# ─────────────────────────────────────────────────────────
if awslocal dynamodb describe-table --table-name "$TABLE_NAME" >/dev/null 2>&1; then
  echo "✅ Table $TABLE_NAME already exists"
else
  echo "→ Creating DynamoDB table: $TABLE_NAME"
  awslocal dynamodb create-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION" \
    >/dev/null
  echo "✅ Table $TABLE_NAME created"
fi

# ─────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 Backend ready for environment: $ENVIRONMENT"
echo "═══════════════════════════════════════════════════════════"
echo "  Bucket:  $BUCKET_NAME"
echo "  Table:   $TABLE_NAME"
echo "  Region:  $REGION"
echo ""
echo "Next step: cd infra/environments/$ENVIRONMENT && tflocal init"

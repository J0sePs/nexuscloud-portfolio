# ═══════════════════════════════════════════════════════════
# Networking layer
#
# Overrides for LocalStack Community compatibility:
#   enable_vpc_endpoints = false (LocalStack has partial support)
# ═══════════════════════════════════════════════════════════

module "networking" {
  source = "../../modules/networking"

  environment          = var.environment
  enable_vpc_endpoints = false # LocalStack Community limitation
  single_nat_gateway   = true  # Cost optimization
}

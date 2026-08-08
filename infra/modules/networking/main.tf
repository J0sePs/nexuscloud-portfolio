# ═══════════════════════════════════════════════════════════
# VPC
# ═══════════════════════════════════════════════════════════

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nexuscloud-${var.environment}-vpc"
  }
}

# ═══════════════════════════════════════════════════════════
# SUBNETS — Public (for ALB and NAT Gateway)
# ═══════════════════════════════════════════════════════════

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "nexuscloud-${var.environment}-public-${var.availability_zones[count.index]}"
    Tier = "public"
    # Kubernetes discovery tag for future EKS ALB Ingress Controller
    "kubernetes.io/role/elb" = "1"
  }
}

# ═══════════════════════════════════════════════════════════
# SUBNETS — Private (for EKS worker nodes, Lambdas in VPC)
# ═══════════════════════════════════════════════════════════

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                              = "nexuscloud-${var.environment}-private-${var.availability_zones[count.index]}"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ═══════════════════════════════════════════════════════════
# SUBNETS — Isolated (for RDS — no internet egress at all)
# ═══════════════════════════════════════════════════════════

resource "aws_subnet" "isolated" {
  count = length(var.isolated_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.isolated_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "nexuscloud-${var.environment}-isolated-${var.availability_zones[count.index]}"
    Tier = "isolated"
  }
}

# ═══════════════════════════════════════════════════════════
# INTERNET GATEWAY (for public subnets)
# ═══════════════════════════════════════════════════════════

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nexuscloud-${var.environment}-igw"
  }
}

# ═══════════════════════════════════════════════════════════
# NAT GATEWAY(S) — for private subnet egress
# ═══════════════════════════════════════════════════════════

locals {
  # Cost optimization: single NAT for dev, one per AZ for prod
  nat_gateway_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : length(var.availability_zones)
  ) : 0
}

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  tags = {
    Name = "nexuscloud-${var.environment}-nat-eip-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = local.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nexuscloud-${var.environment}-nat-${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

# ═══════════════════════════════════════════════════════════
# ROUTE TABLE — Public (routes 0.0.0.0/0 to IGW)
# ═══════════════════════════════════════════════════════════

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "nexuscloud-${var.environment}-public-rt"
    Tier = "public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ═══════════════════════════════════════════════════════════
# ROUTE TABLES — Private (route 0.0.0.0/0 to NAT GW)
# ═══════════════════════════════════════════════════════════

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "nexuscloud-${var.environment}-private-rt-${count.index}"
    Tier = "private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? (
    aws_route_table.private[0].id
    ) : (
    aws_route_table.private[count.index].id
  )
}

# ═══════════════════════════════════════════════════════════
# ROUTE TABLE — Isolated (no internet routes at all)
# ═══════════════════════════════════════════════════════════

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.main.id

  # No routes to internet — VPC-local traffic only
  tags = {
    Name = "nexuscloud-${var.environment}-isolated-rt"
    Tier = "isolated"
  }
}

resource "aws_route_table_association" "isolated" {
  count = length(aws_subnet.isolated)

  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolated.id
}

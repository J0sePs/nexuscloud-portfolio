# ═══════════════════════════════════════════════════════════
# BASELINE SECURITY GROUP — VPC-internal-only allow rule
# Default deny inbound from internet, allow all outbound
# ═══════════════════════════════════════════════════════════

resource "aws_security_group" "vpc_internal" {
  name        = "nexuscloud-${var.environment}-vpc-internal"
  description = "Baseline SG allowing traffic within the VPC only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "All traffic from within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All outbound (further filtering per-service SG)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexuscloud-${var.environment}-vpc-internal-sg"
  }
}

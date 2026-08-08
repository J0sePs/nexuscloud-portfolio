# ═══════════════════════════════════════════════════════════
# VPC ENDPOINTS — S3 and DynamoDB (Gateway type, free)
# Only created when enable_vpc_endpoints = true
#
# NOTE: LocalStack Community 3.8.x has partial support for
# VPC endpoints. Default is disabled to avoid dev-only failures.
# ═══════════════════════════════════════════════════════════

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    [aws_route_table.isolated.id]
  )

  tags = {
    Name = "nexuscloud-${var.environment}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    [aws_route_table.isolated.id]
  )

  tags = {
    Name = "nexuscloud-${var.environment}-dynamodb-endpoint"
  }
}

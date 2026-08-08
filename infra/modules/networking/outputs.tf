output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (for ALB, NAT GW)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (for EKS nodes, Lambdas)"
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "List of isolated subnet IDs (for RDS)"
  value       = aws_subnet.isolated[*].id
}

output "nat_gateway_ips" {
  description = "Public IPs of the NAT Gateway(s), for IP-based allowlisting"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "vpc_internal_security_group_id" {
  description = "SG allowing traffic within the VPC only"
  value       = aws_security_group.vpc_internal.id
}

output "availability_zones" {
  description = "AZs used by this VPC"
  value       = var.availability_zones
}

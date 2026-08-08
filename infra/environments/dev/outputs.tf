output "vpc_id" {
  description = "ID of the primary VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR of the primary VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "isolated_subnet_ids" {
  value = module.networking.isolated_subnet_ids
}

output "nat_gateway_ips" {
  value = module.networking.nat_gateway_ips
}

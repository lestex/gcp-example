output "network_name" {
  value       = module.vpc-network.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.vpc-network.network_self_link
  description = "The name of the VPC being created"
}

output "subnets_self_links" {
  value       = module.vpc-network.subnets_self_links
  description = "The self-links of subnets being created"
}

output "vpc_id" {
  value = google_compute_network.main_vpc.id
}

output "vpc_name" {
  value = google_compute_network.main_vpc.name
}

output "subnet_ids" {
  description = "Map of subnet names to their GCP resource IDs"
  value       = { for k, v in google_compute_subnetwork.subnets : k => v.id }
}

output "wg_subnet_cidrs" {
  description = "List of WireGuard remote subnet CIDRs (useful for VPC routes)"
  value       = [for s in var.wg_subnets : s.cidr]
}


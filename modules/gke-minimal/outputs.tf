output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "endpoint" {
  value     = google_container_cluster.primary.endpoint
  sensitive = true
}

output "ca_certificate" {
  value     = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive = true
}

output "pods_cidr" {
  value = google_container_cluster.primary.ip_allocation_policy[0].cluster_ipv4_cidr_block
}

output "node_service_account" {
  value = google_service_account.gke_nodes.email
}


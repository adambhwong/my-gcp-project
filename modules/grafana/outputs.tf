output "grafana_url" {
  description = "URL to access the Grafana server interface via DNS."
  value       = "https://${trimsuffix(var.dns_domain_name, ".")}"
}

output "load_balancer_ip" {
  description = "The reserved static external IP address of the Load Balancer."
  value       = google_compute_global_address.grafana_lb_ip.address
}

output "service_account_email" {
  description = "The IAM service account attached to the Grafana VM."
  value       = google_service_account.grafana_sa.email
}

output "secret_id" {
  description = "The Secret Manager secret resource ID storing the Grafana admin password."
  value       = google_secret_manager_secret.grafana_password_secret.id
  sensitive   = true
}

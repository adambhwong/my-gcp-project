# Generate a secure random password for Grafana admin
resource "random_password" "grafana_admin_password" {
  length  = 20
  special = false
}

# Create a GCP Secret Manager secret
resource "google_secret_manager_secret" "grafana_password_secret" {
  secret_id = "grafana-admin-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

# Store the generated password inside the Secret Manager version
resource "google_secret_manager_secret_version" "grafana_password_version" {
  secret      = google_secret_manager_secret.grafana_password_secret.id
  secret_data = random_password.grafana_admin_password.result
}

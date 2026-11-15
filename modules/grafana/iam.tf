# Dedicated Service Account for the VM with Monitoring, Logging, and Secret Access
resource "google_service_account" "grafana_sa" {
  account_id   = "grafana-monitoring-sa"
  display_name = "Grafana Monitoring, Logging & Secret Service Account"
  project      = var.project_id
}

# Grant Monitoring Viewer role so Grafana can query GCP Cloud Metrics
resource "google_project_iam_member" "monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.grafana_sa.email}"
}

# Grant Metric Writer role so Grafana can export its own metrics
resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.grafana_sa.email}"
}

# Grant Log Writer role so the instance can send logs to Cloud Logging
resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.grafana_sa.email}"
}

# Grant the VM's Service Account permissions to read the password secret
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.grafana_password_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.grafana_sa.email}"
}
 
# Grant Serice Usage Viewer role
resource "google_project_iam_member" "service_usage_viewer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageViewer"
  member  = "serviceAccount:${google_service_account.grafana_sa.email}"
}
 
# Grant Browser role
resource "google_project_iam_member" "browser" {
  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.grafana_sa.email}"
}

# Dedicated Service Account for the VPN VM (Least Privilege)
resource "google_service_account" "vpn_sa" {
  account_id   = "vpn-gateway-sa"
  display_name = "WireGuard VPN Gateway Service Account"
}

# Allow the VPN VM's Service Account to write logs
resource "google_project_iam_member" "vpn_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vpn_sa.email}"
}

# Grant the VPN VM's Service Account read access to these secrets
resource "google_secret_manager_secret_iam_member" "vpn_secret_access" {
  for_each  = google_secret_manager_secret.wg_secrets
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.vpn_sa.email}"
}


# Allow IAP SSH into the collector VM for troubleshooting
resource "google_compute_firewall" "allow_iap_ssh_prometheus" {
  project  = var.project_id
  name     = "allow-iap-ssh-prometheus-collector"
  network  = var.network_name
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = [google_service_account.prometheus_collector.email]
}


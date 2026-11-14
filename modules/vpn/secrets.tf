# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Generate WireGuard Key Pairs (Server + Peers)
resource "wireguard_asymmetric_key" "server" {}

resource "wireguard_asymmetric_key" "peers" {
  for_each = { for p in var.wg_peers : p.name => p }
}

# Store Server Keys in Secret Manager
locals {
  server_secrets = {
    "wg-server-private-key" = wireguard_asymmetric_key.server.private_key
    "wg-server-public-key"  = wireguard_asymmetric_key.server.public_key
  }

  peer_private_secrets = {
    for k, v in wireguard_asymmetric_key.peers : "wg-peer-${k}-private-key" => v.private_key
  }

  peer_public_secrets = {
    for k, v in wireguard_asymmetric_key.peers : "wg-peer-${k}-public-key" => v.public_key
  }

  all_secrets = merge(local.server_secrets, local.peer_private_secrets, local.peer_public_secrets)
}

resource "google_secret_manager_secret" "wg_secrets" {
  for_each  = local.all_secrets
  secret_id = each.key

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "wg_secret_versions" {
  for_each    = local.all_secrets
  secret      = google_secret_manager_secret.wg_secrets[each.key].id
  secret_data = each.value
}

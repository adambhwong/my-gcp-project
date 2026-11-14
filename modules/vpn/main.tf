# VPC Custom Routes for each remote WireGuard peer subnet
resource "google_compute_route" "wg_routes" {
  for_each = { for p in var.wg_peers : p.name => p }

  name                   = "route-wg-${each.value.name}"
  dest_range             = each.value.cidr
  network                = var.vpc_id
  next_hop_instance      = google_compute_instance_from_template.vpn_gateway.name
  next_hop_instance_zone = google_compute_instance_from_template.vpn_gateway.zone
  priority               = 100
}

# Public DNS A Record
resource "google_dns_record_set" "vpn_dns" {
  name         = "vpn.${var.dns_domain}"
  managed_zone = var.dns_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.vpn_ip.address]
}

# Allow IAP SSH
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh-wireguard"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Google Cloud's dedicated IAP TCP forwarding IP range
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["vpn-gateway"] # Ensure this matches the tags on your WireGuard VM
}

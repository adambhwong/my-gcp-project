resource "google_dns_managed_zone" "gcp_subdomain" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description
  visibility  = var.public ? "public" : "private"

  dynamic "private_visibility_config" {
    for_each = var.public ? [] : [1]
    content {
      networks {
        network_url = var.vpc_id
      }
    }
  }
}


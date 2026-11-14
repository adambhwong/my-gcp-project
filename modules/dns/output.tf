output "name_servers" {
  value = google_dns_managed_zone.gcp_subdomain.name_servers
}

output "zone_name" {
  value = google_dns_managed_zone.gcp_subdomain.name
}

output "dns_name" {
  value = google_dns_managed_zone.gcp_subdomain.dns_name
}


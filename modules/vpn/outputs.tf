output "vpn_public_ip" {
  description = "Static external IP of the WireGuard gateway"
  value       = google_compute_address.vpn_ip.address
}

output "vpn_private_ip" {
  description = "Internal VPC IP of the WireGuard gateway"
  value       = google_compute_instance_from_template.vpn_gateway.network_interface[0].network_ip
}

output "vpn_fqdn" {
  description = "Public DNS hostname for the WireGuard endpoint"
  value       = trimsuffix(google_dns_record_set.vpn_dns.name, ".")
}


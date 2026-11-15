output "instance_name" {
  value = google_compute_instance.collector.name
}

output "internal_ip" {
  value = google_compute_instance.collector.network_interface[0].network_ip
}


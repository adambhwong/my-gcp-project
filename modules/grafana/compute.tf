# Dedicated Persistent Disk for Grafana data persistence
resource "google_compute_disk" "grafana_data_disk" {
  name    = "grafana-data-disk"
  type    = "pd-standard"
  zone    = var.zone
  project = var.project_id
  size    = 10
}

# Firewall rule to allow HTTP access to Grafana on port 3000
resource "google_compute_firewall" "allow_grafana" {
  name    = "allow-grafana-ui"
  network = var.network_name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["grafana-server"]
}

# Allow IAP SSH
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh-grafana"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Google Cloud's dedicated IAP TCP forwarding IP range
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["grafana-server"] # Ensure this matches the tags on your WireGuard VM
}

# Compute Instance Template for Grafana
resource "google_compute_instance_template" "grafana_template" {
  name_prefix  = "grafana-server-template-"
  machine_type = var.machine_type
  project      = var.project_id
  region       = var.region
  tags         = ["grafana-server"]

  disk {
    source_image = "cos-cloud/cos-stable"
    disk_size_gb = 20
    boot         = true
  }

  disk {
    source      = google_compute_disk.grafana_data_disk.name
    mode        = "READ_WRITE"
    boot        = false
    auto_delete = false
  }

  network_interface {
    network = var.network_name
    subnetwork = var.subnet_id
    access_config {
    }
  }

  service_account {
    email  = google_service_account.grafana_sa.email
    scopes = [
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    
    DISK_DEVICE="/dev/sdb"
    MOUNT_DIR="/mnt/disks/grafana-data"

    if !blkid "$DISK_DEVICE"; then
      mkfs.ext4 -F "$DISK_DEVICE"
    fi

    mkdir -p "$MOUNT_DIR"
    mount -o discard,defaults "$DISK_DEVICE" "$MOUNT_DIR"
    chmod 775 "$MOUNT_DIR"

    sudo iptables -I INPUT -p tcp --dport 3000 -j ACCEPT

    docker run -d \
      --name=grafana \
      -p 3000:3000 \
      --restart=always \
      -v "$MOUNT_DIR:/var/lib/grafana" \
      -e "GF_LOG_MODE=console" \
      -e "GF_LOG_LEVEL=info" \
      -e "GF_METRICS_ENABLED=true" \
      -e "GF_SECURITY_ADMIN_USER=admin" \
      -e "GF_SECURITY_ADMIN_PASSWORD=${random_password.grafana_admin_password.result}" \
      -e "GF_SERVER_DOMAIN=${trimsuffix(var.dns_domain_name, ".")}" \
      -e "GF_SERVER_ROOT_URL=https://${trimsuffix(var.dns_domain_name, ".")}/" \
      grafana/grafana:latest
  EOT

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_secret_manager_secret_version.grafana_password_version
  ]
}

# Managed Instance Group (MIG) configured for a single instance
resource "google_compute_instance_group_manager" "grafana_mig" {
  name               = "grafana-server-mig"
  base_instance_name = "grafana-server"
  zone               = var.zone
  project            = var.project_id
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.grafana_template.id
  }

  # Named port mapping required by the External Application Load Balancer backend service
  named_port {
    name = "grafana"
    port = 3000
  }
}

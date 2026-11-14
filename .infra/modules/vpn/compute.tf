# Static IP & Persistent Data Disk
resource "google_compute_address" "vpn_ip" {
  name   = "vpn-gateway-ip"
  region = var.region
}

resource "google_compute_disk" "vpn_data" {
  name = "vpn-gateway-data"
  type = "pd-standard"
  zone = var.zone
  size = 10
}

# Instance Template (COS) loading secrets into wg0.conf on boot
locals {
  wg_conf_template = templatefile("${path.module}/templates/wg0.conf.tftpl", {
    server_address = var.wg_server_address
    peers          = var.wg_peers
  })
}

resource "google_compute_instance_template" "vpn_template" {
  name_prefix    = "vpn-gateway-tpl-"
  machine_type   = var.machine_type
  region         = var.region
  tags           = ["vpn-gateway"]
  can_ip_forward = true

  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {
      nat_ip = google_compute_address.vpn_ip.address
    }
  }

  service_account {
    email  = google_service_account.vpn_sa.email
    scopes = ["cloud-platform"]
  }

  # Enables COS built-in Cloud Logging daemon for host/kernel logs
  metadata = {
    google-logging-enabled = "true"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # 1. Mount persistent disk
    DISK_DEV="/dev/disk/by-id/google-wg-data"
    MOUNT_DIR="/var/lib/wireguard"
    mkdir -p "$MOUNT_DIR"
    if ! blkid "$DISK_DEV"; then
      mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard "$DISK_DEV"
    fi
    mount -o discard,defaults "$DISK_DEV" "$MOUNT_DIR"
    mkdir -p "$MOUNT_DIR/config/wg_confs"

    # 2. Enable forwarding & load kernel module
    sysctl -w net.ipv4.ip_forward=1
    iptables -P FORWARD ACCEPT
    modprobe wireguard

    # 3. Helper function to fetch a secret from Secret Manager
    get_secret() {
      local secret_name="$1"
      local token
      token=$(curl -s -H "Metadata-Flavor: Google" \
        "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

      curl -s -H "Authorization: Bearer $token" \
        "https://secretmanager.googleapis.com/v1/projects/${var.project_id}/secrets/$secret_name/versions/latest:access" \
        | python3 -c "import sys, json, base64; print(base64.b64decode(json.load(sys.stdin)['payload']['data']).decode())"
    }

    # 4. Write the rendered wg0.conf template
    WG_CONF="$MOUNT_DIR/config/wg_confs/wg0.conf"
    cat <<'WGCONF' > "$WG_CONF"
${local.wg_conf_template}
WGCONF

    # 5. Inject Server Private Key and Peer Public Keys from Secret Manager
    SERVER_PRIV_KEY=$(get_secret "wg-server-private-key")
    sed -i "s|__SERVER_PRIVATE_KEY__|$SERVER_PRIV_KEY|g" "$WG_CONF"

    %{ for peer in var.wg_peers ~}
    PEER_KEY=$(get_secret "wg-peer-${peer.name}-public-key")
    sed -i "s|__PEER_PUBLIC_KEY_${peer.name}__|$PEER_KEY|g" "$WG_CONF"
    %{ endfor ~}

    chmod 600 "$WG_CONF"

    # 6. Start or restart the WireGuard container
    if [ ! "$(docker ps -aq -f name=^wireguard$)" ]; then
      docker run -d \
        --name=wireguard \
        --cap-add=NET_ADMIN \
        --network=host \
        --log-driver=gcplogs \
        --log-opt gcp-project="${var.project_id}" \
        --log-opt labels="app" \
        --label app="wireguard" \
        -e PUID=1000 \
        -e PGID=1000 \
        -e TZ=Europe/London \
        -v "$MOUNT_DIR/config:/config" \
        --restart unless-stopped \
        lscr.io/linuxserver/wireguard:latest
    else
      docker restart wireguard
    fi
  EOF

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_secret_manager_secret_version.wg_secret_versions,
    google_secret_manager_secret_iam_member.vpn_secret_access,
    google_project_iam_member.vpn_log_writer
  ]
}

# Create VPN Instance from Template
resource "google_compute_instance_from_template" "vpn_gateway" {
  name                     = "vpn-gateway"
  zone                     = var.zone
  source_instance_template = google_compute_instance_template.vpn_template.self_link

  attached_disk {
    source      = google_compute_disk.vpn_data.id
    device_name = "wg-data"
  }
}


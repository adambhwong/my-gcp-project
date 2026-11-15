locals {
  prometheus_config = templatefile("${path.module}/templates/prometheus.yml.tftpl", {
    scrape_targets = var.scrape_targets
  })  
}

resource "google_compute_instance" "collector" {
  project      = var.project_id
  name         = "prometheus-collector"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  service_account {
    email  = google_service_account.prometheus_collector.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    google-logging-enabled = "true"

    user-data = <<-EOF
      #cloud-config
      write_files:
        - path: /etc/prometheus/prometheus.yml
          encoding: b64
          permissions: "0644"
          owner: root:root
          content: ${base64encode(local.prometheus_config)}

        - path: /etc/systemd/system/gmp-collector.service
          permissions: "0644"
          owner: root:root
          content: |
            [Unit]
            Description=Google Managed Service for Prometheus Collector
            After=docker.service network-online.target
            Wants=network-online.target
            Requires=docker.service

            [Service]
            Restart=always
            RestartSec=10
            ExecStartPre=-/usr/bin/docker rm -f gmp-collector
            ExecStart=/usr/bin/docker run --rm --name gmp-collector \
              --network host \
              -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
              ${var.gmp_image} \
              --config.file=/etc/prometheus/prometheus.yml \
              --storage.tsdb.path=/tmp/prometheus \
              --export.match='{job="home-linux-nodes", __name__=~"up|node_cpu_seconds_total|node_memory_.*|node_filesystem_.*|node_network_.*|node_load.*|node_boot_time_seconds"}'
            ExecStop=/usr/bin/docker stop gmp-collector

            [Install]
            WantedBy=multi-user.target

      runcmd:
        - systemctl daemon-reload
        - systemctl enable --now gmp-collector.service
    EOF
  }

  lifecycle {
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
      #metadata
    ]
  }
}


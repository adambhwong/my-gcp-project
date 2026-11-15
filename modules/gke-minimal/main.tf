resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.zone # Zonal cluster (single zone avoids multi-zone replication overhead)

  network    = var.network_name
  subnetwork = var.subnet_id

  # Remove default node pool immediately so we manage a custom node pool cleanly
  remove_default_node_pool = true
  initial_node_count       = 1

  # VPC-native IP allocation (automatically creates secondary IP ranges on the subnet if not pre-created)
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  # Disable the public control plane endpoint and assign a private /28 endpoint
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Allow subnets to reach the private control plane IP
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Enable Google Cloud Managed Service for Prometheus (GMP)
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # Enable Workload Identity for pods
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Allow Terraform to destroy the cluster cleanly during homelab experiments
  deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "${var.cluster_name}-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = 30
    disk_type    = "pd-balanced"
    spot         = var.use_spot_nodes

    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Required for Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    tags = ["gke-node", var.cluster_name]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}


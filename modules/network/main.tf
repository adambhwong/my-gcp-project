resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create a subnetwork for each object in var.subnets
resource "google_compute_subnetwork" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  name                     = "${each.value.name}-${var.region}"
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  network                  = google_compute_network.main_vpc.id
  private_ip_google_access = true
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router-${var.region}"
  region  = var.region
  network = google_compute_network.main_vpc.id
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "nat-gateway-${var.region}"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_internal_vpc" {
  name     = "allow-internal-main-vpc"
  network  = google_compute_network.main_vpc.id
  priority = 1000

  allow {
    protocol = "all"
  }

  source_ranges = [ for s in var.subnets : s.cidr ]
}

resource "google_compute_firewall" "allow_wireguard" {
  name    = "allow-wireguard-udp"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vpn-gateway"]
}

# Allow traffic from all CIDRs defined in var.wg_subnets
resource "google_compute_firewall" "allow_wg_subnets" {
  name    = "allow-wg-subnets-to-vpc"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = [for s in var.wg_subnets : s.cidr]
}


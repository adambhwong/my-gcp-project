locals {
  region = "europe-west2"
  zone   = "europe-west2-a"
  subnets = [
    {
      name = "vm-subnet"
      cidr = "10.10.1.0/24"
    }
  ]
  wg_server_address = "10.2.0.1/32"
  wg_peers = [
    {
      name      = "home-hk"
      tunnel_ip = "10.2.0.2/32"
      cidr      = "192.168.1.0/24"
    },
    {
      name      = "home-uk"
      tunnel_ip = "10.2.0.3/32"
      cidr      = "192.168.15.0/24"
    },
  ]
}

# Network Module
module "network" {
  source = "./modules/network"
  region = local.region

  subnets = local.subnets

  wg_subnets = [
    for p in local.wg_peers : {
      name = p.name
      cidr = p.cidr
    }
  ]
}

# Artifact Registry Module
module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = data.google_project.default.project_id
  region     = local.region
}

# Cloud DNS Module
module "dns" {
  source    = "./modules/dns"
  zone_name = "gcp-2am-xyz"
  dns_name  = "gcp.2am.xyz."
  description = "Delegated from DNSimple"
  public = true
  vpc_id = module.network.vpc_id
}

module "vpn" {
  source            = "./modules/vpn"
  project_id        = data.google_project.default.project_id
  region            = local.region
  zone              = local.zone
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.subnet_ids["vm-subnet"]
  vpc_subnet_cidrs  = [for s in local.subnets : s.cidr]
  wg_server_address = local.wg_server_address
  wg_peers          = local.wg_peers
  dns_zone_name     = module.dns.zone_name
  dns_domain        = module.dns.dns_name
  machine_type      = "e2-micro"
}

# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "iap.googleapis.com"
  disable_on_destroy = false
}


locals {
  region = "europe-west2"
  zone   = "europe-west2-a"
  enable_services = [
    "iap",
    "networkmanagement",
    "logging",
    "monitoring",
    "secretmanager",
    "container",
    "dns",
    "artifactregistry"
  ]
  subnets = [
    {
      name = "vm-subnet"
      cidr = "10.10.1.0/24"
    }
  ]
  wg_server_address = "10.2.0.1/24"
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
  prometheus_scrape_targets = {
    beetle = {
      target   = "192.168.15.175:9100"
      instance = "beetle"
      location = "home-uk"
    }
    panda = {
      target   = "192.168.1.2:9100"
      instance = "panda"
      location = "home-hk"
    }
  }

  #  gke_cluster = {
  #    name                     = "testlab"
  #    master_ipv4_cidr_block   = "10.10.255.0/28"
  #    pods_ipv4_cidr_block     = "10.20.0.0/16"
  #    services_ipv4_cidr_block = "10.21.0.0/20"
  #    node_machine_type        = "e2-medium"
  #    node_count               = 1
  #    use_spot_nodes           = true
  #  }
}

# Enable services
resource "google_project_service" "default" {
  for_each           = { for s in local.enable_services : s => {} }
  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
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

  depends_on = [google_project_service.default]
}

# Artifact Registry Module
module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = data.google_project.default.project_id
  region     = local.region

  depends_on = [google_project_service.default]
}

# Cloud DNS Module
module "dns" {
  source      = "./modules/dns"
  zone_name   = "gcp-2am-xyz"
  dns_name    = "gcp.2am.xyz."
  description = "Delegated from DNSimple"
  public      = true
  vpc_id      = module.network.vpc_id

  depends_on = [google_project_service.default]
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

  depends_on = [
    google_project_service.default,
    module.network,
    module.dns
  ]
}

module "prometheus_collector" {
  source         = "./modules/prometheus-collector"
  count          = local.prometheus_scrape_targets == {} ? 0 : 1
  project_id     = data.google_project.default.project_id
  zone           = local.zone
  network_name   = module.network.vpc_name
  subnet_id      = values(module.network.subnet_ids)[0]
  scrape_targets = local.prometheus_scrape_targets

  depends_on = [
    google_project_service.default,
    module.network,
    module.vpn
  ]
}

#locals {
#  wg_authorized_cidrs = concat(
#    flatten([
#      for peer in local.wg_peers : [
#        {
#          cidr_block   = peer.cidr
#          display_name = peer.name
#        }
#      ]
#      ]), flatten([
#      for subnet in local.subnets : [
#        {
#          cidr_block   = subnet.cidr
#          display_name = subnet.name
#        }
#      ]
#    ])
#  )
#}
#
#module "gke_cluster" {
#  source                        = "./modules/gke-minimal"
#  project_id                    = data.google_project.default.project_id
#  cluster_name                  = local.gke_cluster.name
#  zone                          = local.zone
#  network_name                  = module.network.vpc_name
#  subnet_id                     = values(module.network.subnet_ids)[0]
#  pods_ipv4_cidr_block          = local.gke_cluster.pods_ipv4_cidr_block
#  services_ipv4_cidr_block      = local.gke_cluster.services_ipv4_cidr_block
#  node_machine_type             = local.gke_cluster.node_machine_type
#  node_count                    = local.gke_cluster.node_count
#  use_spot_nodes                = local.gke_cluster.use_spot_nodes
#  master_authorized_cidr_blocks = local.wg_authorized_cidrs
#
#  depends_on = [
#    google_project_service.default,
#    module.network
#  ]
#}


# Enable services
resource "google_project_service" "default" {
  for_each           = { for s in var.enable_services : s => {} }
  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
}

# Network Module
module "network" {
  source = "./modules/network"
  region = var.region

  subnets = var.subnets

  wg_subnets = [
    for p in var.wg_peers : {
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
  region     = var.region

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
  region            = var.region
  zone              = var.zone
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.subnet_ids["vm-subnet"]
  vpc_subnet_cidrs  = [for s in var.subnets : s.cidr]
  wg_server_address = var.wg_server_address
  wg_peers          = var.wg_peers
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
  count          = var.prometheus_scrape_targets == {} ? 0 : 1
  project_id     = data.google_project.default.project_id
  zone           = var.zone
  network_name   = module.network.vpc_name
  subnet_id      = values(module.network.subnet_ids)[0]
  scrape_targets = var.prometheus_scrape_targets

  depends_on = [
    google_project_service.default,
    module.network,
    module.vpn
  ]
}

module "grafana" {
  source          = "./modules/grafana"
  project_id      = data.google_project.default.project_id
  region          = var.region
  zone            = var.zone
  network_name    = module.network.vpc_name
  subnet_id       = values(module.network.subnet_ids)[0]
  dns_zone_name   = module.dns.zone_name
  dns_domain_name = "${var.grafana.host}.${module.dns.dns_name}"

  depends_on = [
    google_project_service.default,
    module.network,
    module.dns
  ]
}


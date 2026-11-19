module "gke_cluster" {
  source                        = "./modules/gke-minimal"
  for_each                      = { for c in var.gke_clusters : c.name => c }
  project_id                    = data.google_project.default.project_id
  cluster_name                  = each.value.name
  master_authorized_cidr_blocks = each.value.master_authorized_cidr_blocks
  pods_ipv4_cidr_block          = each.value.pods_ipv4_cidr_block
  services_ipv4_cidr_block      = each.value.services_ipv4_cidr_block
  zone                          = each.value.zone == "" ? var.zone : each.value.zone
  network_name                  = each.value.network_name == "" ? module.network.vpc_name : each.value.network_name
  subnet_id                     = each.value.subnet_id == "" ? values(module.network.subnet_ids)[0] : each.value.subnet_id
  node_machine_type             = each.value.node_machine_type
  node_count                    = each.value.node_count
  use_spot_nodes                = each.value.use_spot_nodes

  depends_on = [
    google_project_service.default,
    module.network
  ]
}


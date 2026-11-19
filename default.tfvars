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
  "artifactregistry",
  "serviceusage",
  "iamcredentials",
  "sts",
]

subnets = [
  {
    name = "vm-subnet"
    cidr = "10.10.1.0/24"
  },
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
  tiger = {
    target   = "192.168.15.244:9100"
    instance = "tiger"
    location = "home-uk"
  }
}

grafana = {
  host = "monitoring"
}

github_repo = "adambhwong/my-gcp-project"

gke_clusters = [{
  name                     = "testlab"
  master_ipv4_cidr_block   = "10.10.255.0/28"
  pods_ipv4_cidr_block     = "10.20.0.0/16"
  services_ipv4_cidr_block = "10.21.0.0/20"
  master_authorized_cidr_blocks = [
    {
      cidr_block   = "192.168.15.0/24"
      display_name = "home-uk"
    }
  ]
}]

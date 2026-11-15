variable "region" {
  type        = string
  default     = "europe-west2"
  description = "GCP region for VPC resources"
}

variable "zone" {
  type        = string
  default     = "europe-west2-a"
  description = "GCP zone for VPC resources"
}

variable "enable_services" {
  type = list(string)
  default = [
    "iap",
    "networkmanagement",
    "logging",
    "monitoring",
    "secretmanager",
    "container",
    "dns",
    "artifactregistry",
    "serviceusage"
  ]
  description = "List services to enable"
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = [
    {
      name = "vm-subnet"
      cidr = "10.10.1.0/24"
    }
  ]
  description = "List of subnets"
}

variable "wg_server_address" {
  type        = string
  default     = "10.2.0.1/24"
  description = "GCP VM wireguard server address"
}

variable "wg_peers" {
  type = list(object({
    name      = string
    cidr      = string
    tunnel_ip = string
  }))
  default = []
  description = "List of wireguard peers"
}

variable "prometheus_scrape_targets" {
  type = map(object({
    target   = string
    instance = string
    location = string
  }))
  default = {}
  description = "Map of prometheus scape targets"
}

variable "grafana" {
  type = object({
    host = string
  })
  default = {
    host = "monitoring"
  }
  description = "Grafana configurations"
}

variable "github_repo" {
  type        = string
  default     = "adambhwong/my-gcp-project"
  description = "Github repository (your-github-org/your-repo-name)"
}


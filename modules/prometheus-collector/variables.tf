variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "zone" {
  description = "GCP Zone for the collector VM"
  type        = string
  default     = "europe-west2-a"
}

variable "network_name" {
  description = "VPC network name (e.g., main-vpc)"
  type        = string
}

variable "subnet_id" {
  description = "Subnetwork ID (10.10.1.0/24 subnet)"
  type        = string
}

variable "machine_type" {
  description = "Compute Engine machine type"
  type        = string
  default     = "e2-micro"
}

variable "gmp_image" {
  description = "Google Managed Service for Prometheus collector image"
  type        = string
  default     = "gke.gcr.io/prometheus-engine/prometheus:v2.53.5-gmp.1-gke.2"
}

variable "scrape_targets" {
  description = "Map of home Linux nodes to scrape"
  type = map(object({
    target   = string
    instance = string
    location = string
  }))
  default = {}
}


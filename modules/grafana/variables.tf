variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The target GCP region."
  type        = string
}

variable "zone" {
  description = "The target GCP zone for the VM."
  type        = string
}

variable "network_name" {
  description = "The VPC network name to deploy the VM into."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnetwork to deploy the VM into"
  type        = string
}

variable "machine_type" {
  description = "GCE machine type for Grafana."
  type        = string
  default     = "e2-small"
}

variable "dns_zone_name" {
  description = "The name of the existing Cloud DNS managed zone."
  type        = string
  default     = "gcp-2am-xyz"
}

variable "dns_domain_name" {
  description = "The fully qualified domain name for Grafana."
  type        = string
  default     = "monitoring.gcp.2am.xyz."
}

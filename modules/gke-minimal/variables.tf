variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "zone" {
  description = "GCP Zone for the zonal GKE cluster (e.g., europe-west2-a)"
  type        = string
  default     = "europe-west2-a"
}

variable "network_name" {
  description = "VPC network name or self_link (e.g., main-vpc)"
  type        = string
}

variable "subnet_id" {
  description = "Subnetwork self_link or ID for GKE nodes (e.g., 10.10.1.0/24)"
  type        = string
}

variable "pods_ipv4_cidr_block" {
  description = "Secondary CIDR block for GKE Pods (must not overlap with 10.10.0.0/16 or 10.2.0.0/24)"
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_ipv4_cidr_block" {
  description = "Secondary CIDR block for GKE Services"
  type        = string
  default     = "10.21.0.0/20"
}

variable "node_machine_type" {
  description = "Machine type for GKE worker nodes (e2-medium is the practical minimum for GKE system pods + GMP)"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "Number of nodes in the zonal node pool"
  type        = number
  default     = 1
}

variable "use_spot_nodes" {
  description = "Use Spot VMs to reduce GKE node cost by ~60-80%"
  type        = bool
  default     = false
}

variable "master_authorized_cidr" {
  description = "CIDR allowed to access the GKE control plane endpoint (restrict to your home IP or VPN CIDR)"
  type        = string
  default     = "0.0.0.0/0"
}


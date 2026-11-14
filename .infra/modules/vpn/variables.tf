variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region for the static IP and VPN gateway"
}

variable "zone" {
  type        = string
  description = "GCP availability zone for the VPN VM (e.g., europe-west2-a)"
}

variable "vpc_id" {
  type        = string
  description = "VPC network ID where custom routes will be attached"
}

variable "subnet_id" {
  type        = string
  description = "Subnetwork ID where the VPN VM will be deployed"
}

variable "wg_server_address" {
  type        = string
  default     = "10.13.13.1/24"
  description = "WireGuard server tunnel interface IP/CIDR (e.g., 10.13.13.1/24)"
}

variable "vpc_subnet_cidrs" {
  type        = list(string)
  description = "List of VPC subnet CIDRs to include in peer AllowedIPs"
}

variable "wg_peers" {
  type = list(object({
    name      = string
    tunnel_ip = string # e.g., "10.13.13.2/32"
    cidr      = string # Remote LAN CIDR, e.g., "192.168.1.0/24"
  }))
  description = "WireGuard peers and their remote subnets"
}

variable "dns_zone_name" {
  type        = string
  description = "Cloud DNS public zone name for the VPN A record"
}

variable "dns_domain" {
  type        = string
  description = "Cloud DNS domain name (with trailing dot, e.g., gcp.2am.xyz.)"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Compute Engine machine type (e.g., e2-micro)"
}


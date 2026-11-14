variable "zone_name" {
  type        = string
  description = "Cloud DNS managed zone resource name"
}

variable "dns_name" {
  type        = string
  description = "Delegated DNS domain name (must end with a trailing dot)"
}

variable "description" {
  type        = string
  description = "Managed zone description"
}

variable "public" {
  type        = bool
  description = "Is this a public zone"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "VPC network self_link/ID required when creating private DNS zones"
}

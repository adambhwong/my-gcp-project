variable "region" {
  type        = string
  description = "GCP region for VPC resources"
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
  description = "List of VPC subnets to create"
}

variable "wg_subnets" {
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
  description = "List of remote WireGuard subnets allowed to communicate with the VPC"
}


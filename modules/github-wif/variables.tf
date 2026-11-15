variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "pool_id" {
  type        = string
  description = "The ID of the Workload Identity Pool."
  default     = "github-pool"
}

variable "provider_id" {
  type        = string
  description = "The ID of the Workload Identity Pool Provider."
  default     = "github-provider"
}

variable "service_account" {
  type        = string
  default     = "terraform-admin"
  description = "The service account used for the GitHub Actions."
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository in the format 'owner/repo' (e.g., 'my-org/my-repo')."
}

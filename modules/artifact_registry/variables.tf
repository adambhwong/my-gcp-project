variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region for the Docker repository"
}

variable "repository_id" {
  type        = string
  default     = "docker-images"
  description = "Artifact Registry repository name"
}


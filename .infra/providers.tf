terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "project-ab555a93-7f84-4481-947-tfstate"
    prefix = "base"
  }
}

provider "google" {
  project = "project-ab555a93-7f84-4481-947"
  region  = "europe-west2"
}


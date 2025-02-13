terraform {
  required_version = ">= 0.13.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The ID of your GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy the Redis instance"
  type        = string
  default     = "us-central1"
}
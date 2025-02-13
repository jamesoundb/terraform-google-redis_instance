terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "google" {
  project = "test-project"
  region  = "us-central1"
}

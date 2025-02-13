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
  project     = "test-project"
  region      = "us-central1"
  credentials = <<EOF
{
  "type": "service_account",
  "project_id": "test-project",
  "private_key_id": "mock-key-id",
  "private_key": "mock-key",
  "client_email": "test@test-project.iam.gserviceaccount.com",
  "client_id": "mock-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/test@test-project.iam.gserviceaccount.com"
}
EOF
}

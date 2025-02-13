variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "configuration_validation" {
  command = plan

  variables {
    project_id          = var.project_id
    name                = "redis-e2e-test"
    region              = "us-central1"
    zone                = "us-central1-a"
    secondary_zone      = "us-central1-b"
    memory_size_gb      = 5
    tier                = "STANDARD_HA"
    authorized_network  = "projects/${var.project_id}/global/networks/default"
    reserved_ip_range   = "10.0.0.0/29"
    auth_enabled        = true
    redis_version       = "REDIS_6_X"
    persistence_enabled = true
  }

  assert {
    condition     = var.zone != var.secondary_zone
    error_message = "Primary and secondary zones must be different"
  }
}
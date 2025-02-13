variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "network_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis-integration"
    region            = "us-central1"
    zone              = "us-central1-a"
    secondary_zone    = "us-central1-b"
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    reserved_ip_range = "10.0.1.0/28"
  }

  assert {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.reserved_ip_range))
    error_message = "Reserved IP range must be a valid CIDR block"
  }
}
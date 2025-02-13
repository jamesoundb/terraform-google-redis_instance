variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "custom_network_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-redis-custom"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/custom-network"
    reserved_ip_range  = "10.0.1.0/24"
  }

  assert {
    condition     = can(regex("^10\\.0\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", var.reserved_ip_range))
    error_message = "Reserved IP range should be a valid CIDR block"
  }

  assert {
    condition     = can(regex("^projects/.+/global/networks/.+$", var.authorized_network))
    error_message = "Authorized network should be a valid GCP network ID"
  }
}

run "custom_network_ip_range_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-redis-custom"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/custom-network"
    reserved_ip_range  = "invalid-cidr"
  }

  expect_failures = [
    google_redis_instance.cache,
  ]
}

run "custom_network_labels_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-redis-custom"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/custom-network"
    reserved_ip_range  = "10.0.1.0/28"
    labels = {
      environment = "prod"
      network     = "custom"
      managed-by  = "terraform"
    }
  }

  assert {
    condition     = length(var.labels) > 0
    error_message = "Labels should be provided for resource management"
  }

  assert {
    condition     = contains(keys(var.labels), "environment")
    error_message = "Environment label should be present"
  }
}

run "custom_network_auth_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-redis-custom"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/custom-network"
    reserved_ip_range  = "10.0.1.0/28"
    auth_enabled       = true
    redis_version      = "REDIS_6_X"
  }

  assert {
    condition     = var.auth_enabled == true
    error_message = "Authentication should be enabled for production environments"
  }
}
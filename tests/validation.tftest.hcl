variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "validate_required_configuration" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-validation-test"
    region             = "us-central1"
    zone               = "us-central1-a"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    secondary_zone     = "us-central1-b"
  }

  assert {
    condition     = google_redis_instance.cache[0].memory_size_gb >= 1
    error_message = "Redis instance must have at least 1GB memory"
  }

  assert {
    condition     = google_redis_instance.cache[0].region == "us-central1"
    error_message = "Redis instance must be in us-central1"
  }
}

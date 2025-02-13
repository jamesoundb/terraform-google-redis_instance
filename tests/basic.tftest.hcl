variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "basic_redis_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis"
    region            = "us-central1"
    zone              = "us-central1-a"
    memory_size_gb    = 1
    tier              = "BASIC"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    auth_enabled      = true
    redis_version     = "REDIS_6_X"
  }

  assert {
    condition     = var.tier == "BASIC"
    error_message = "Redis instance tier should be BASIC"
  }
}
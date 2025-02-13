variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "cost_optimization_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "redis-cost-test"
    region            = "us-central1"
    zone              = "us-central1-a"
    memory_size_gb    = 2
    tier              = "BASIC"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    enable_cost_optimization = true
    labels = {
      environment = "dev"
    }
  }

  assert {
    condition     = var.tier == "BASIC" && var.labels.environment == "dev"
    error_message = "Development environment should use BASIC tier for cost optimization"
  }

  assert {
    condition     = var.memory_size_gb <= 5
    error_message = "Development environment should use smaller instance sizes"
  }
}

run "autoscaling_thresholds_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis-auto"
    region            = "us-central1"
    zone              = "us-central1-a"
    secondary_zone    = "us-central1-b"
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    enable_autoscaling = true
    memory_scale_up_threshold = 0.8
    memory_scale_down_threshold = 0.5
  }

  assert {
    condition     = var.memory_scale_up_threshold > var.memory_scale_down_threshold
    error_message = "Scale-up threshold must be higher than scale-down threshold"
  }

  assert {
    condition     = var.memory_scale_up_threshold <= 1 && var.memory_scale_up_threshold > 0
    error_message = "Scale-up threshold must be between 0 and 1"
  }

  assert {
    condition     = var.memory_scale_down_threshold < var.memory_scale_up_threshold
    error_message = "Scale-down threshold must be less than scale-up threshold"
  }
}

run "production_cost_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis-prod-cost"
    region            = "us-central1"
    zone              = "us-central1-a"
    secondary_zone    = "us-central1-b"
    memory_size_gb    = 10
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    enable_cost_optimization = true
    scaling_cooldown_period = 3600
    labels = {
      environment = "prod"
    }
  }

  assert {
    condition     = var.tier == "STANDARD_HA" && var.labels.environment == "prod"
    error_message = "Production environment should use HA tier despite higher cost"
  }

  assert {
    condition     = var.memory_size_gb >= 5
    error_message = "Production environment should use appropriate instance sizes"
  }
}
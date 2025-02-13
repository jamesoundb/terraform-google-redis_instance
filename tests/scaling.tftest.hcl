variables {
  test_project_id = "var.project_id"
  test_region     = "us-central1"
  test_zones = {
    primary   = "us-central1-a"
    secondary = "us-central1-b"
  }
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "scaling_config_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-scaling-test"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    enable_autoscaling          = true
    scaling_cooldown_period     = 3600
    scaling_evaluation_period   = 300
    memory_scale_up_threshold   = 0.85
    memory_scale_down_threshold = 0.4
    persistence_enabled         = true
    persistence_mode            = "RDB"
    rdb_snapshot_period         = "TWENTY_FOUR_HOURS"
    maintenance_window_day      = "MONDAY"
    maintenance_window_hour     = 2
    maintenance_window_minutes  = 30
  }

  assert {
    condition     = var.enable_autoscaling
    error_message = "Autoscaling should be enabled"
  }

  assert {
    condition     = var.memory_scale_up_threshold > var.memory_scale_down_threshold
    error_message = "Scale-up threshold must be higher than scale-down threshold"
  }

  assert {
    condition     = var.scaling_cooldown_period >= 1800
    error_message = "Cooldown period must be at least 30 minutes"
  }
}

run "tier_upgrade_validation" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-tier-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    memory_size_gb     = 5
    tier               = "BASIC"
    authorized_network = "projects/${var.test_project_id}/global/networks/default"

    enable_autoscaling = true
    uptime_requirement = 0.99
  }

  assert {
    condition     = var.tier == "BASIC" && var.uptime_requirement >= 0.99
    error_message = "High uptime requirement should suggest HA tier upgrade"
  }
}

run "scaling_thresholds_validation" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-threshold-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.test_project_id}/global/networks/default"

    memory_scale_up_threshold   = 0.8
    memory_scale_down_threshold = 0.3
    scaling_evaluation_period   = 600
  }

  assert {
    condition     = var.memory_scale_up_threshold >= 0.6 && var.memory_scale_up_threshold <= 0.9
    error_message = "Scale-up threshold should be within reasonable range"
  }

  assert {
    condition     = var.memory_scale_down_threshold >= 0.2 && var.memory_scale_down_threshold <= 0.5
    error_message = "Scale-down threshold should be within reasonable range"
  }
}

run "combined_scaling_validation" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-combined-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.test_project_id}/global/networks/default"

    enable_autoscaling          = true
    enable_performance_analysis = true
    workload_type               = "cache"
    scaling_cooldown_period     = 3600
    memory_scale_up_threshold   = 0.85
    memory_scale_down_threshold = 0.4
  }

  assert {
    condition     = var.enable_autoscaling && var.enable_performance_analysis
    error_message = "Both autoscaling and performance analysis should be enabled"
  }

  assert {
    condition     = var.workload_type != null
    error_message = "Workload type should be specified for optimal scaling"
  }
}

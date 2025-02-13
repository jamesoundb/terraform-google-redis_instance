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

run "performance_monitoring_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-perf-test"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    enable_performance_monitoring  = true
    memory_fragmentation_threshold = 1.5
    latency_threshold_ms           = 10
    cache_hit_rate_threshold       = 0.8
    persistence_enabled            = true
    persistence_mode               = "RDB"
    rdb_snapshot_period            = "TWENTY_FOUR_HOURS"
    maintenance_window_day         = "MONDAY"
    maintenance_window_hour        = 2
    maintenance_window_minutes     = 30
  }

  assert {
    condition     = var.enable_performance_monitoring
    error_message = "Performance monitoring should be enabled"
  }

  assert {
    condition     = var.memory_fragmentation_threshold >= 1.0
    error_message = "Memory fragmentation threshold must be >= 1.0"
  }

  assert {
    condition     = var.latency_threshold_ms > 0
    error_message = "Latency threshold must be positive"
  }

  assert {
    condition     = var.cache_hit_rate_threshold > 0 && var.cache_hit_rate_threshold <= 1
    error_message = "Cache hit rate threshold must be between 0 and 1"
  }
}

run "performance_thresholds_validation" {
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

    memory_fragmentation_threshold = 2.0
    latency_threshold_ms           = 5
    cache_hit_rate_threshold       = 0.9
  }

  assert {
    condition     = var.memory_fragmentation_threshold < 3.0
    error_message = "Memory fragmentation threshold too high"
  }

  assert {
    condition     = var.latency_threshold_ms < 100
    error_message = "Latency threshold too high for production use"
  }

  assert {
    condition     = var.cache_hit_rate_threshold > 0.7
    error_message = "Cache hit rate threshold too low for optimal performance"
  }
}

run "ha_performance_config" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-ha-perf-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 10
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.test_project_id}/global/networks/default"

    enable_performance_monitoring  = true
    memory_fragmentation_threshold = 1.5
    latency_threshold_ms           = 8
    cache_hit_rate_threshold       = 0.85
  }

  assert {
    condition     = var.tier == "STANDARD_HA"
    error_message = "Performance testing requires HA tier"
  }

  assert {
    condition     = var.memory_size_gb >= 10
    error_message = "HA performance testing requires larger instance size"
  }

  assert {
    condition     = var.secondary_zone != null && var.secondary_zone != var.zone
    error_message = "HA configuration requires distinct secondary zone"
  }
}

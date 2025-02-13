variables {
  project_id  = "test-project-id"
  test_region = "us-central1"
  test_zones = {
    primary   = "us-central1-a"
    secondary = "us-central1-b"
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "performance_analysis_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-analysis-test"
    region             = "us-central1"
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    enable_performance_analysis      = true
    analysis_window                  = 3600
    enable_automated_recommendations = true
    recommendation_sensitivity       = "medium"
    persistence_enabled              = true
    persistence_mode                 = "RDB"
    rdb_snapshot_period              = "TWENTY_FOUR_HOURS"
    maintenance_window_day           = "MONDAY"
    maintenance_window_hour          = 2
    maintenance_window_minutes       = 30
  }

  assert {
    condition     = var.enable_performance_analysis
    error_message = "Performance analysis should be enabled"
  }

  assert {
    condition     = var.analysis_window >= 300 && var.analysis_window <= 86400
    error_message = "Analysis window should be within valid range"
  }
}

run "performance_thresholds_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-thresholds-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    performance_score_thresholds = {
      memory_efficiency_min = 0.7
      latency_score_min     = 0.75
      throughput_score_min  = 0.8
      overall_health_min    = 0.75
    }
  }

  assert {
    condition     = alltrue([for v in values(var.performance_score_thresholds) : v >= 0 && v <= 1])
    error_message = "Performance score thresholds must be between 0 and 1"
  }
}

run "workload_analysis_recommendations" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-workload-analysis"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    workload_type                    = "cache"
    enable_performance_analysis      = true
    enable_automated_recommendations = true
    recommendation_sensitivity       = "high"
  }

  assert {
    condition     = var.workload_type != null && var.enable_automated_recommendations
    error_message = "Workload analysis should be enabled with recommendations"
  }

  assert {
    condition     = contains(["low", "medium", "high"], var.recommendation_sensitivity)
    error_message = "Invalid recommendation sensitivity level"
  }
}

run "analysis_metrics_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-metrics-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    enable_performance_analysis = true
  }

  assert {
    condition     = var.enable_performance_analysis
    error_message = "Performance analysis metrics should be enabled"
  }
}

run "combined_analysis_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-combined-test"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    enable_performance_analysis      = true
    enable_automated_recommendations = true
    workload_type                    = "cache"
    performance_score_thresholds = {
      memory_efficiency_min = 0.8
      latency_score_min     = 0.85
      throughput_score_min  = 0.9
      overall_health_min    = 0.85
    }
  }

  assert {
    condition     = var.enable_performance_analysis && var.enable_automated_recommendations
    error_message = "Both performance analysis and recommendations should be enabled"
  }

  assert {
    condition     = var.workload_type != null
    error_message = "Workload type should be specified for analysis"
  }

  assert {
    condition     = var.performance_score_thresholds.overall_health_min >= 0.8
    error_message = "Production workloads should have high performance thresholds"
  }
}

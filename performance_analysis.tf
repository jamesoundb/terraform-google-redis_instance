locals {
  performance_analysis_configs = {
    memory_analysis = {
      high_usage_threshold    = 0.85
      fragmentation_threshold = 1.5
      growth_rate_threshold   = 0.1
    }
    latency_analysis = {
      p95_threshold_ms = 10
      p99_threshold_ms = 20
      max_threshold_ms = 50
    }
    throughput_analysis = {
      ops_per_second_threshold = 10000
      bandwidth_mb_threshold   = 100
      client_threshold         = 5000
    }
  }

  workload_recommendations = {
    cache = {
      maxmemory_samples  = 10
      active_defrag      = true
      eviction_samples   = 10
      master_persistence = false
    }
    session = {
      maxmemory_samples  = 5
      active_defrag      = false
      eviction_samples   = 5
      master_persistence = true
    }
    queue = {
      maxmemory_samples  = 3
      active_defrag      = true
      eviction_samples   = 3
      master_persistence = true
    }
  }
}

resource "google_monitoring_metric_descriptor" "performance_analysis" {
  count = var.enable_performance_analysis ? 1 : 0

  project      = var.project_id
  description  = "Redis performance analysis metric for ${var.name}"
  display_name = "Redis Performance Score - ${var.name}"
  type         = "custom.googleapis.com/redis/${var.name}/performance_score"
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"

  labels {
    key         = "analysis_type"
    value_type  = "STRING"
    description = "Type of performance analysis"
  }
}

resource "google_monitoring_dashboard" "performance_analysis" {
  dashboard_json = jsonencode({
    displayName = "Redis Performance Analysis - ${var.name}"
    gridLayout = {
      widgets = [
        {
          title = "Memory Fragmentation"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/memory/fragmentation_ratio\""
                }
              }
            }]
          }
        },
        {
          title = "Command Statistics"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/commands_total\""
                }
              }
            }]
          }
        },
        {
          title = "Network Traffic"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND (metric.type=\"redis.googleapis.com/network/bytes_in\" OR metric.type=\"redis.googleapis.com/network/bytes_out\")"
                }
              }
            }]
          }
        }
      ]
    }
  })
  project = var.project_id
}

resource "google_monitoring_alert_policy" "performance_degradation" {
  count = var.enable_performance_analysis ? 1 : 0

  display_name = "Redis Performance Degradation Alert - ${var.name}"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Overall Performance Score"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"custom.googleapis.com/redis/${var.name}/performance_score\" AND metric.label.analysis_type=\"overall\""
      duration        = "300s"
      comparison      = "COMPARISON_LT"
      threshold_value = 0.7

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = <<-EOT
      Performance degradation detected for Redis instance ${var.name}

      Analysis types:
      - Memory efficiency
      - Latency performance
      - Throughput capacity

      Recommended actions:
      1. Review performance analysis dashboard
      2. Check Redis configuration settings
      3. Consider scaling or optimization options
    EOT
    mime_type = "text/markdown"
  }

  notification_channels = var.alert_notification_channels
}

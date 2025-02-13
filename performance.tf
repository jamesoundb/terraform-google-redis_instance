locals {
  performance_thresholds = {
    memory_usage_percent = 90
    cpu_usage_percent    = 80
    key_evictions_rate   = 1000
  }
}

resource "google_monitoring_alert_policy" "performance_alerts" {
  count = var.enable_alerts ? 1 : 0

  display_name = "Redis Performance Alerts"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "High Memory Usage"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.memory_threshold

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = "High resource utilization detected on Redis instance ${var.name}"
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
  alert_strategy {
    auto_close = "86400s"
  }
}

resource "google_monitoring_dashboard" "performance" {
  count = var.create_monitoring_dashboard ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis Performance Dashboard"
    gridLayout = {
      widgets = [
        {
          title = "Memory Usage"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
                }
              }
            }]
          }
        },
        {
          title = "Evicted Keys"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/evicted_keys\""
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
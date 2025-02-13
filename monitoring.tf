resource "google_monitoring_alert_policy" "redis_auth_failures" {
  count        = var.enable_alerts ? 1 : 0
  display_name = "Redis Authentication Failures"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "High auth failure rate"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/auth/failures\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.auth_failures_threshold

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = "High number of Redis authentication failures detected. This may indicate unauthorized access attempts."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
  alert_strategy {
    auto_close = "86400s"
  }
}

resource "google_monitoring_alert_policy" "redis_connection_spikes" {
  count        = var.enable_alerts ? 1 : 0
  display_name = "Redis Connection Spikes"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Connection spike detected"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/stats/connected_clients\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.connections_threshold

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = "Sudden spike in Redis connections detected. This may indicate a traffic surge or potential DoS attempt."
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
  alert_strategy {
    auto_close = "86400s"
  }
}

resource "google_monitoring_dashboard" "redis_security" {
  count = var.enable_optional_security_features ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis Security Dashboard - ${var.name}"
    gridLayout = {
      widgets = [
        {
          title = "Authentication Failures"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/auth/failures\""
                }
              }
            }]
          }
        },
        {
          title = "Connection Rate"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/connections\""
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

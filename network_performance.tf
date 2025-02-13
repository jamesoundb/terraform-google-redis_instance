locals {
  network_thresholds = {
    latency_threshold_ms      = 5
    connection_count_warning  = 1000
    connection_rejection_rate = 10
  }
}

resource "google_compute_firewall" "redis_firewall" {
  count   = var.create_firewall_rules ? 1 : 0
  name    = "redis-${var.name}-firewall"
  network = var.authorized_network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }

  source_tags = var.allowed_source_tags
  target_tags = ["redis-${var.name}"]

  # Only allow internal traffic
  source_ranges = var.allowed_ip_ranges
}

resource "google_monitoring_alert_policy" "network_alerts" {
  count        = var.enable_alerts ? 1 : 0
  display_name = "Redis Network Performance Alerts"
  combiner     = "OR"
  conditions {
    display_name = "Network error rate"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/network/errors\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.network_error_threshold
    }
  }

  notification_channels = var.notification_channels
  alert_strategy {
    auto_close = "86400s"
  }
}

resource "google_monitoring_dashboard" "network_performance" {
  count = var.enable_network_monitoring ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis Network Performance - ${var.name}"
    gridLayout = {
      widgets = [
        {
          title = "Network Round-Trip Latency"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/network/round_trip_latency\""
                }
              }
            }]
          }
        },
        {
          title = "Connected Clients"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/connected_clients\""
                }
              }
            }]
          }
        },
        {
          title = "Connection Rejection Rate"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/rejected_connections\""
                }
              }
            }]
          }
        },
        {
          title = "Network Bytes In/Out"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/network/bytes_in\""
                  }
                }
              },
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/network/bytes_out\""
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
  project = var.project_id
}
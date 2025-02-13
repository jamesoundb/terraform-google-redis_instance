locals {
  scaling_thresholds = {
    memory = {
      scale_up_threshold   = min(0.85, var.memory_scale_up_threshold)
      scale_down_threshold = max(0.4, var.memory_scale_down_threshold)
      cooldown_period      = var.scaling_cooldown_period
    }
    connections = {
      scale_up_threshold   = var.max_connections_threshold * 0.8
      scale_down_threshold = var.max_connections_threshold * 0.3
      cooldown_period      = var.scaling_cooldown_period
    }
  }

  scaling_recommendations = {
    memory_size_options = [1, 2, 4, 8, 16, 32, 64, 128]
    tier_upgrade_conditions = {
      high_availability       = var.tier == "BASIC" && var.uptime_requirement >= 0.99
      performance_requirement = var.performance_score_thresholds.overall_health_min >= 0.9
    }
  }
}

resource "google_monitoring_metric_descriptor" "scaling_metrics" {
  count = var.enable_autoscaling ? 1 : 0

  project      = var.project_id
  description  = "Redis scaling recommendation metric for ${var.name}"
  display_name = "Redis Scaling Score - ${var.name}"
  type         = "custom.googleapis.com/redis/${var.name}/scaling_recommendation"
  metric_kind  = "GAUGE"
  value_type   = "INT64"

  labels {
    key         = "recommendation_type"
    value_type  = "STRING"
    description = "Type of scaling recommendation"
  }
}

resource "google_monitoring_alert_policy" "scaling_recommendation" {
  count = var.enable_autoscaling ? 1 : 0

  display_name = "Redis Scaling Recommendation Alert - ${var.name}"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Memory Usage Scale Up"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
      duration        = "${var.scaling_evaluation_period}s"
      comparison      = "COMPARISON_GT"
      threshold_value = local.scaling_thresholds.memory.scale_up_threshold

      trigger {
        count = 1
      }
    }
  }

  conditions {
    display_name = "Memory Usage Scale Down"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
      duration        = "${var.scaling_evaluation_period * 2}s"
      comparison      = "COMPARISON_LT"
      threshold_value = local.scaling_thresholds.memory.scale_down_threshold

      trigger {
        count = 1
      }
    }
  }

  conditions {
    display_name = "Connection Count Scale Up"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/connected_clients\""
      duration        = "${var.scaling_evaluation_period}s"
      comparison      = "COMPARISON_GT"
      threshold_value = local.scaling_thresholds.connections.scale_up_threshold

      trigger {
        count = 1
      }
    }
  }

  documentation {
    content   = <<-EOT
      Scaling recommendation for Redis instance ${var.name}

      Current configuration:
      - Memory: ${var.memory_size_gb} GB
      - Tier: ${var.tier}
      - Max Connections: ${var.max_connections_threshold}

      Available scaling options:
      - Memory sizes: ${jsonencode(local.scaling_recommendations.memory_size_options)}
      - Tier upgrade available: ${local.scaling_recommendations.tier_upgrade_conditions.high_availability}

      Note: Please review the performance analysis dashboard before applying scaling changes.
      Cooldown period: ${var.scaling_cooldown_period} seconds
    EOT
    mime_type = "text/markdown"
  }

  notification_channels = var.alert_notification_channels
}

resource "google_monitoring_dashboard" "scaling_analysis" {
  count = var.enable_autoscaling ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis Scaling Analysis - ${var.name}"
    gridLayout = {
      widgets = [
        {
          title = "Memory Usage Trend"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
                }
              }
            }]
          }
        },
        {
          title = "Connection Count Trend"
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
          title = "Scaling Recommendations"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"custom.googleapis.com/redis/${var.name}/scaling_recommendation\""
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
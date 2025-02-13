locals {
  workload_metrics = {
    cache = [
      "redis.googleapis.com/stats/cache/hit_ratio",
      "redis.googleapis.com/stats/cache/miss_ratio",
      "redis.googleapis.com/stats/memory/usage_ratio",
      "redis.googleapis.com/stats/keyspace/keys_tracked"
    ]
    session = [
      "redis.googleapis.com/stats/keyspace/expires",
      "redis.googleapis.com/stats/persistence/rdb_changes",
      "redis.googleapis.com/stats/cpu/usage_ratio",
      "redis.googleapis.com/stats/connections/connected_clients"
    ]
    queue = [
      "redis.googleapis.com/stats/lists/length",
      "redis.googleapis.com/stats/commands/processed",
      "redis.googleapis.com/stats/memory/fragmentation_ratio",
      "redis.googleapis.com/stats/keyspace/keys_tracked"
    ]
  }

  selected_metrics = var.workload_type != null ? local.workload_metrics[var.workload_type] : []
}

resource "google_monitoring_metric_descriptor" "workload_metrics" {
  for_each = var.workload_type != null ? toset(local.selected_metrics) : []

  project      = var.project_id
  description  = "Redis ${var.workload_type} workload metric: ${each.key}"
  display_name = "Redis ${title(var.workload_type)} - ${each.key}"
  type         = each.key
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"

  labels {
    key         = "instance_name"
    value_type  = "STRING"
    description = "Name of the Redis instance"
  }

  labels {
    key         = "workload_type"
    value_type  = "STRING"
    description = "Type of Redis workload"
  }
}

resource "google_monitoring_dashboard" "workload_metrics" {
  count = var.workload_type != null ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis ${title(var.workload_type)} Workload Metrics - ${var.name}"
    gridLayout = {
      widgets = [for metric in local.selected_metrics : {
        title = replace(split("/", metric)[length(split("/", metric)) - 1], "_", " ")
        xyChart = {
          dataSets = [{
            timeSeriesQuery = {
              timeSeriesFilter = {
                filter = "resource.type=\"redis_instance\" AND metric.type=\"${metric}\""
              }
              unitOverride = "1"
            }
          }]
          timeshiftDuration = "0s"
          yAxis = {
            label = "y1Axis"
            scale = "LINEAR"
          }
        }
      }]
    }
  })

  project = var.project_id
}

resource "google_monitoring_alert_policy" "workload_alerts" {
  count = var.workload_type != null ? 1 : 0

  project      = var.project_id
  display_name = "Redis ${title(var.workload_type)} Workload Alerts - ${var.name}"
  combiner     = "OR"

  conditions {
    display_name = "Cache Hit Rate Alert"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/cache/hit_ratio\""
      duration        = "300s"
      comparison      = "COMPARISON_LT"
      threshold_value = var.workload_type == "cache" ? 0.8 : 0.5
    }
  }

  conditions {
    display_name = "Memory Usage Alert"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/memory/usage_ratio\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.9
    }
  }

  conditions {
    display_name = "Connection Count Alert"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/connections/connected_clients\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.max_connections_threshold
    }
  }

  notification_channels = var.alert_notification_channels

  documentation {
    content   = <<-EOT
      Workload-specific alerts for ${var.name} (${var.workload_type}):

      Metrics being monitored:
      ${join("\n", local.selected_metrics)}

      Thresholds are optimized for ${var.workload_type} workload pattern.
      Review the Redis configuration if alerts persist.
    EOT
    mime_type = "text/markdown"
  }
}

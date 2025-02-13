locals {
  is_production = contains(values(var.labels), "prod")
}

resource "google_monitoring_metric_descriptor" "redis_utilization" {
  count       = var.enable_autoscaling ? 1 : 0
  description = "Redis memory utilization metric for autoscaling"

  display_name = "Redis Memory Utilization - ${var.name}"
  project      = var.project_id
  type         = "custom.googleapis.com/redis/${var.name}/memory_utilization"
  metric_kind  = "GAUGE"
  value_type   = "DOUBLE"
  unit         = "1"

  labels {
    key         = "instance_name"
    value_type  = "STRING"
    description = "The name of the Redis instance"
  }
}

resource "google_monitoring_dashboard" "cost_optimization" {
  count = var.enable_cost_optimization ? 1 : 0

  dashboard_json = jsonencode({
    displayName = "Redis Cost Optimization Dashboard - ${var.name}"
    gridLayout = {
      widgets = [
        {
          title = "Memory Utilization"
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
          title = "Connection Count"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/connections\""
                }
              }
            }]
          }
        },
        {
          title = "Cache Hit Rate"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"redis_instance\" AND metric.type=\"redis.googleapis.com/stats/cache/hit_ratio\""
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

# Cost optimization recommendations
resource "null_resource" "cost_optimization_check" {
  count = var.enable_cost_optimization ? 1 : 0

  triggers = {
    memory_size = google_redis_instance.cache[0].memory_size_gb
    tier        = google_redis_instance.cache[0].tier
  }

  provisioner "local-exec" {
    command = <<EOT
      if [ "${google_redis_instance.cache[0].tier}" = "STANDARD_HA" ] && [ ${google_redis_instance.cache[0].memory_size_gb} -lt 5 ]; then
        echo "Warning: HA tier may not be cost-effective for instances < 5GB"
      fi
      if [ "${local.is_production}" = "false" ] && [ "${google_redis_instance.cache[0].tier}" = "STANDARD_HA" ]; then
        echo "Warning: Consider using non-HA tier for non-production environments"
      fi
    EOT
  }

  lifecycle {
    precondition {
      condition = (
        google_redis_instance.cache[0].memory_size_gb >= 5 ||
        google_redis_instance.cache[0].tier != "STANDARD_HA"
      )
      error_message = "For HA tier, memory size must be at least 5GB"
    }

    precondition {
      condition = (
        !local.is_production ||
        google_redis_instance.cache[0].tier != "BASIC"
      )
      error_message = "Production environments should use HA tier"
    }
  }
}

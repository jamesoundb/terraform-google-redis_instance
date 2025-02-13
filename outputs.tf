output "id" {
  description = "The Redis instance ID"
  value       = google_redis_instance.cache[0].id
}

output "host" {
  description = "The IP address of the Redis instance"
  value       = google_redis_instance.cache[0].host
}

output "port" {
  description = "The port number of the Redis instance"
  value       = google_redis_instance.cache[0].port
}

output "region" {
  description = "The region the Redis instance is located in"
  value       = google_redis_instance.cache[0].region
}

output "current_location_id" {
  description = "The current zone where the Redis endpoint is placed"
  value       = google_redis_instance.cache[0].current_location_id
}

output "persistence_iam_identity" {
  description = "IAM identity used for import/export operations"
  value       = google_redis_instance.cache[0].persistence_iam_identity
}

output "auth_string" {
  description = "AUTH string for authenticating with Redis instance"
  value       = google_redis_instance.cache[0].auth_string
  sensitive   = true
}

output "monitoring_resources" {
  description = "Monitoring resource IDs"
  value = {
    alert_policies = compact([
      var.enable_alerts ? google_monitoring_alert_policy.redis_auth_failures[0].name : "",
      var.enable_alerts ? google_monitoring_alert_policy.redis_connection_spikes[0].name : "",
      var.enable_alerts ? google_monitoring_alert_policy.performance_alerts[0].name : "",
      var.persistence_enabled ? google_monitoring_alert_policy.backup_failure[0].name : "",
      var.enable_alerts ? google_monitoring_alert_policy.network_alerts[0].name : ""
    ])
    dashboards = compact([
      var.create_monitoring_dashboard ? google_monitoring_dashboard.performance[0].id : "",
      var.create_monitoring_dashboard ? google_monitoring_dashboard.network_performance[0].id : ""
    ])
  }
}

output "workload_performance" {
  description = "Workload performance configuration"
  value = var.workload_type != null ? {
    pattern       = local.workload_patterns[var.workload_type]
    redis_configs = google_redis_instance.cache[0].redis_configs
  } : null
}
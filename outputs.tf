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

output "memory_size_gb" {
  description = "The memory size of the Redis instance in GB"
  value       = google_redis_instance.cache[0].memory_size_gb
}

output "security_config" {
  description = "Security configuration of the Redis instance"
  value = {
    auth_enabled            = var.auth_enabled
    transit_encryption_mode = google_redis_instance.cache[0].transit_encryption_mode
    maintenance_policy      = google_redis_instance.cache[0].maintenance_policy
    customer_managed_key    = var.customer_managed_key
  }
}

output "network_security" {
  description = "Network security configuration"
  value = {
    authorized_network = google_redis_instance.cache[0].authorized_network
    connect_mode       = google_redis_instance.cache[0].connect_mode
    reserved_ip_range  = google_redis_instance.cache[0].reserved_ip_range
  }
  sensitive = true
}

output "performance_metrics" {
  description = "Performance metrics configuration and thresholds"
  value = {
    instance_id = google_redis_instance.cache[0].id
    metrics = {
      memory = {
        total_bytes_allocated = "memcache.googleapis.com/stats/bytes"
        evicted_items         = "memcache.googleapis.com/stats/evicted_items"
        items_count           = "memcache.googleapis.com/stats/items"
      }
      operations = {
        gets_per_sec = "memcache.googleapis.com/stats/get_requests"
        sets_per_sec = "memcache.googleapis.com/stats/set_requests"
        hits_per_sec = "memcache.googleapis.com/stats/hit_ratio"
      }
      connections = {
        current_connections  = "memcache.googleapis.com/stats/curr_connections"
        rejected_connections = "memcache.googleapis.com/stats/rejected_connections"
      }
    }
  }
}

output "performance_config" {
  description = "Performance configuration settings"
  value = {
    memory_settings = {
      maxmemory_policy  = google_redis_instance.cache[0].redis_configs["maxmemory-policy"]
      maxmemory_samples = try(google_redis_instance.cache[0].redis_configs["maxmemory-samples"], null)
    }
    connection_settings = {
      client_timeout = var.client_timeout
      tcp_keepalive  = var.tcp_keepalive
    }
    maintenance = {
      defrag_settings = var.defrag_settings
    }
    advanced_configs = google_redis_instance.cache[0].redis_configs
  }
}

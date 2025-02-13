locals {
  workload_patterns = {
    cache = {
      maxmemory_policy       = "allkeys-lru"
      notify_keyspace_events = "Ex"
      max_memory_samples     = 10
    }
    session = {
      maxmemory_policy       = "volatile-lru"
      notify_keyspace_events = "Kx"
      max_memory_samples     = 5
    }
    queue = {
      maxmemory_policy       = "noeviction"
      notify_keyspace_events = "Klg"
      max_memory_samples     = 3
    }
  }

  selected_pattern = var.workload_type != null ? local.workload_patterns[var.workload_type] : null
}

# Redis Instance
resource "google_redis_instance" "cache" {
  count          = var.use_redis_cluster ? 0 : 1
  project        = var.project_id
  name           = var.name
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  location_id    = var.zone

  alternative_location_id = var.secondary_zone
  authorized_network      = var.authorized_network
  redis_version           = var.redis_version
  display_name            = var.display_name
  reserved_ip_range       = var.reserved_ip_range
  labels                  = var.labels
  auth_enabled            = var.auth_enabled

  maintenance_policy {
    weekly_maintenance_window {
      day = var.maintenance_window_day
      start_time {
        hours   = var.maintenance_window_hour
        minutes = var.maintenance_window_minutes
        seconds = 0
        nanos   = 0
      }
    }
  }

  dynamic "persistence_config" {
    for_each = var.persistence_enabled ? [1] : []
    content {
      persistence_mode    = var.persistence_mode
      rdb_snapshot_period = var.rdb_snapshot_period
    }
  }

  redis_configs = merge(
    {
      maxmemory-policy  = try(local.selected_pattern.maxmemory_policy, var.workload_type == "cache" ? "allkeys-lru" : (var.workload_type == "session" ? "noeviction" : "volatile-lru"))
      maxmemory-samples = try(local.selected_pattern.max_memory_samples, var.workload_type == "cache" ? "10" : (var.workload_type == "session" ? "5" : "3"))
      activedefrag      = var.workload_type != "session" ? "yes" : "no"
    },
    var.redis_configs
  )

  lifecycle {
    precondition {
      condition     = var.reserved_ip_range == null || can(cidrhost(var.reserved_ip_range, 0))
      error_message = "The reserved_ip_range must be a valid CIDR range"
    }

    precondition {
      condition     = var.tier != "STANDARD_HA" || var.secondary_zone != null
      error_message = "Secondary zone is required for HA tier"
    }

    precondition {
      condition     = var.secondary_zone == null || var.zone != var.secondary_zone
      error_message = "Primary and secondary zones must be different"
    }
  }
}
variable "project_id" {
  description = "The project ID to manage the Redis resources"
  type        = string
}

variable "name" {
  description = "The name of the Redis instance"
  type        = string
}

variable "region" {
  description = "The GCP region to use"
  type        = string
}

variable "zone" {
  description = "The zone where the Redis instance will be deployed"
  type        = string
}

variable "tier" {
  description = "The service tier of the instance"
  type        = string
  default     = "STANDARD_HA"
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB"
  type        = number
}

variable "redis_version" {
  description = "The version of Redis software"
  type        = string
  default     = "REDIS_6_X"
}

variable "display_name" {
  description = "An arbitrary and optional user-provided name for the instance"
  type        = string
  default     = null
}

variable "reserved_ip_range" {
  description = "The CIDR range of internal addresses that are reserved for this instance"
  type        = string
  default     = null
}

variable "secondary_zone" {
  description = "The secondary zone for HA deployment"
  type        = string
  default     = null
}

variable "authorized_network" {
  description = "The full name of the Google Compute Engine network to which the instance is connected"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable monitoring dashboard and alerts"
  type        = bool
  default     = true
}

variable "enable_network_monitoring" {
  description = "Enable network monitoring dashboard"
  type        = bool
  default     = true
}

variable "alert_notification_channels" {
  description = "List of notification channel IDs for alerts"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Resource labels to represent user-provided metadata"
  type        = map(string)
  default     = {}
}

variable "maintenance_window_day" {
  description = "The day of week for maintenance window"
  type        = string
  default     = "SUNDAY"
}

variable "maintenance_window_hour" {
  description = "The hour of day for maintenance window"
  type        = number
  default     = 2
}

variable "maintenance_window_minutes" {
  description = "The minutes after hour for maintenance window"
  type        = number
  default     = 0
}

variable "persistence_enabled" {
  description = "Enable data persistence"
  type        = bool
  default     = false
}

variable "persistence_mode" {
  description = "The persistence mode for Redis data"
  type        = string
  default     = "RDB"
}

variable "rdb_snapshot_period" {
  description = "The snapshot period for RDB persistence"
  type        = string
  default     = "ONE_HOUR"
}

variable "backup_region" {
  description = "The region where backup storage bucket will be created"
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 14
}

variable "cross_region_backup" {
  description = "Enable cross-region backup"
  type        = bool
  default     = false
}

variable "force_destroy_backup" {
  description = "Force destroy backup storage bucket"
  type        = bool
  default     = false
}

variable "auth_enabled" {
  description = "Indicates whether OSS Redis AUTH is enabled"
  type        = bool
  default     = true
}

variable "workload_type" {
  description = "The type of workload (cache, session, queue)"
  type        = string
  default     = null

  validation {
    condition = anytrue([
      var.workload_type == null,
      var.workload_type == "cache",
      var.workload_type == "session",
      var.workload_type == "queue"
    ])
    error_message = "Workload type must be one of: cache, session, queue"
  }
}

variable "enable_backup" {
  description = "Whether to enable backup for the Redis instance"
  type        = bool
  default     = false
}

variable "backup_regions" {
  description = "List of regions for backup configuration"
  type        = list(string)
  default     = []
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling"
  type        = bool
  default     = false
}

variable "memory_scale_up_threshold" {
  description = "Memory usage threshold for scaling up"
  type        = number
  default     = 0.85
}

variable "memory_scale_down_threshold" {
  description = "Memory usage threshold for scaling down"
  type        = number
  default     = 0.4
}

variable "scaling_cooldown_period" {
  description = "Cooldown period between scaling operations in seconds"
  type        = number
  default     = 300
}

variable "scaling_evaluation_period" {
  description = "The period (in seconds) over which to evaluate scaling metrics"
  type        = number
  default     = 300 # 5 minutes
}

variable "max_connections_threshold" {
  description = "Maximum number of connections threshold"
  type        = number
  default     = 1000
}

variable "enable_cost_optimization" {
  description = "Whether to enable cost optimization features"
  type        = bool
  default     = true
}

variable "create_custom_roles" {
  description = "Whether to create custom IAM roles"
  type        = bool
  default     = false
}

variable "create_service_account" {
  description = "Whether to create a service account"
  type        = bool
  default     = false
}

variable "admin_members" {
  description = "List of members to be given admin access"
  type        = list(string)
  default     = []
}

variable "viewer_members" {
  description = "List of members to be given viewer access"
  type        = list(string)
  default     = []
}

variable "enable_vpc_sc" {
  description = "Whether to enable VPC Service Controls"
  type        = bool
  default     = false
}

variable "access_policy_id" {
  description = "The ID of the access policy to use for VPC SC"
  type        = string
  default     = null
}

variable "vpc_sc_access_levels" {
  description = "List of access levels for VPC SC"
  type        = list(string)
  default     = []
}

variable "enable_optional_security_features" {
  description = "Whether to enable optional security features"
  type        = bool
  default     = false
}

variable "create_firewall_rules" {
  description = "Whether to create firewall rules"
  type        = bool
  default     = false
}

variable "allowed_source_tags" {
  description = "List of source tags for firewall rules"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for firewall rules"
  type        = list(string)
  default     = []
}

variable "enable_performance_analysis" {
  description = "Whether to enable performance analysis"
  type        = bool
  default     = false
}

variable "uptime_requirement" {
  description = "Required uptime percentage"
  type        = number
  default     = 0.99
}

variable "performance_score_thresholds" {
  description = "Performance score thresholds"
  type = object({
    overall_health_min = number
  })
  default = {
    overall_health_min = 0.9
  }
}

variable "use_redis_cluster" {
  description = "Whether to create a Redis cluster instead of a single instance"
  type        = bool
  default     = false
}

variable "shard_count" {
  description = "Number of shards in the Redis cluster"
  type        = number
  default     = 3
}

variable "replica_count" {
  description = "Number of replicas per shard in the Redis cluster"
  type        = number
  default     = 1
}

variable "node_type" {
  description = "The Redis node type for cluster mode"
  type        = string
  default     = "REDIS_STANDARD_HA"
}

variable "redis_configs" {
  description = "Additional Redis configuration parameters. For details, see: https://cloud.google.com/memorystore/docs/redis/configuring-redis-instance#setting-server-parameters"
  type        = map(string)
  default     = {}
}

variable "monitor_connections" {
  description = "Enable monitoring of Redis connections"
  type        = bool
  default     = true
}

variable "backup_bucket" {
  description = "The name of the GCS bucket to store Redis backups"
  type        = string
  default     = null
}

variable "notification_channels" {
  description = "The list of notification channel IDs for alerting"
  type        = list(string)
  default     = []
}

variable "auth_failures_threshold" {
  description = "The threshold for authentication failures before alerting"
  type        = number
  default     = 10
}

variable "connections_threshold" {
  description = "The threshold for connection spikes before alerting"
  type        = number
  default     = 1000
}

variable "network_error_threshold" {
  description = "The threshold for network errors before alerting"
  type        = number
  default     = 5
}

variable "memory_threshold" {
  description = "The threshold for memory usage before alerting"
  type        = number
  default     = 90
}

variable "enable_alerts" {
  description = "Whether to enable monitoring alerts"
  type        = bool
  default     = true
}

variable "create_monitoring_dashboard" {
  description = "Whether to create a monitoring dashboard"
  type        = bool
  default     = true
}

variable "network_latency_threshold_ms" {
  description = "The threshold for network latency in milliseconds before alerting"
  type        = number
  default     = 5
}

variable "connection_rejection_threshold" {
  description = "The threshold for connection rejections before alerting"
  type        = number
  default     = 20
}

variable "enable_performance_monitoring" {
  description = "Whether to enable detailed performance monitoring"
  type        = bool
  default     = false
}

variable "enable_automated_recommendations" {
  description = "Whether to enable automated performance recommendations"
  type        = bool
  default     = false
}

variable "memory_fragmentation_threshold" {
  description = "The threshold for memory fragmentation before alerting"
  type        = number
  default     = 1.5
}

variable "recommendation_sensitivity" {
  description = "The sensitivity level for performance recommendations (low, medium, high)"
  type        = string
  default     = "medium"
  validation {
    condition     = contains(["low", "medium", "high"], var.recommendation_sensitivity)
    error_message = "Recommendation sensitivity must be one of: low, medium, high"
  }
}

variable "latency_threshold_ms" {
  description = "The threshold for Redis operation latency in milliseconds"
  type        = number
  default     = 10
}

variable "cache_hit_rate_threshold" {
  description = "The minimum acceptable cache hit rate (between 0 and 1)"
  type        = number
  default     = 0.8
  validation {
    condition     = var.cache_hit_rate_threshold >= 0 && var.cache_hit_rate_threshold <= 1
    error_message = "Cache hit rate threshold must be between 0 and 1"
  }
}
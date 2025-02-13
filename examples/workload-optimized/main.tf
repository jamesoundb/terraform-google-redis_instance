provider "google" {
  project = var.project_id
  region  = var.region
}

# Cache-optimized Redis instance
module "redis_cache" {
  source = "../../"

  project_id = var.project_id
  name       = "redis-cache"
  region     = var.region
  zone       = "${var.region}-a"

  memory_size_gb     = 5
  tier               = "STANDARD_HA"
  authorized_network = var.vpc_network

  # Cache-specific workload optimization
  workload_type = "cache"

  # Performance tuning
  enable_performance_monitoring  = true
  memory_fragmentation_threshold = 1.3
  latency_threshold_ms           = 5
  cache_hit_rate_threshold       = 0.85

  # Network optimization
  enable_network_monitoring    = true
  max_connections_threshold    = 2000
  network_latency_threshold_ms = 2

  # Labels for workload identification
  labels = {
    workload_type = "cache"
    optimization  = "high-throughput"
  }
}

# Session store Redis instance
module "redis_session" {
  source = "../../"

  project_id = var.project_id
  name       = "redis-session"
  region     = var.region
  zone       = "${var.region}-a"

  memory_size_gb     = 3
  tier               = "STANDARD_HA"
  authorized_network = var.vpc_network

  # Session-specific workload optimization
  workload_type = "session"

  # Performance settings via redis_configs
  redis_configs = {
    "timeout"                       = "300"
    "tcp-keepalive"                 = "60"
    "activedefrag"                  = "yes"
    "active-defrag-threshold-lower" = "10"
    "active-defrag-threshold-upper" = "100"
    "active-defrag-cycle-min"       = "5"
    "active-defrag-cycle-max"       = "25"
  }

  # Labels for workload identification
  labels = {
    workload_type = "session"
    optimization  = "persistence"
  }
}

# Queue-optimized Redis instance
module "redis_queue" {
  source = "../../"

  project_id = var.project_id
  name       = "redis-queue"
  region     = var.region
  zone       = "${var.region}-a"

  memory_size_gb     = 4
  tier               = "STANDARD_HA"
  authorized_network = var.vpc_network

  # Queue-specific workload optimization
  workload_type = "queue"

  # Redis configurations for queue optimization
  redis_configs = {
    "stream-node-max-bytes"   = "4096"
    "stream-node-max-entries" = "100"
    "list-max-ziplist-size"   = "-2"
  }

  # Labels for workload identification
  labels = {
    workload_type = "queue"
    optimization  = "throughput"
  }
}

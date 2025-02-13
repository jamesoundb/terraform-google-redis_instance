output "redis_instances" {
  description = "Redis instance details for each workload type"
  value = {
    cache = {
      host = module.redis_cache.host
      port = module.redis_cache.port
      configuration = {
        workload_type       = "cache"
        maxmemory_policy    = "allkeys-lru"
        performance_metrics = module.redis_cache.performance_metrics
      }
    }
    session = {
      host = module.redis_session.host
      port = module.redis_session.port
      configuration = {
        workload_type       = "session"
        maxmemory_policy    = "volatile-lru"
        performance_metrics = module.redis_session.performance_metrics
      }
    }
    queue = {
      host = module.redis_queue.host
      port = module.redis_queue.port
      configuration = {
        workload_type       = "queue"
        maxmemory_policy    = "noeviction"
        performance_metrics = module.redis_queue.performance_metrics
      }
    }
  }
}

output "monitoring_dashboards" {
  description = "Monitoring dashboard URLs for each workload type"
  value = {
    cache   = module.redis_cache.monitoring_resources
    session = module.redis_session.monitoring_resources
    queue   = module.redis_queue.monitoring_resources
  }
}

output "performance_configurations" {
  description = "Performance configurations for each instance"
  value = {
    cache = {
      memory_fragmentation_threshold = module.redis_cache.performance_config.memory_fragmentation_threshold
      latency_threshold_ms           = module.redis_cache.performance_config.latency_threshold_ms
      cache_hit_rate_threshold       = module.redis_cache.performance_config.cache_hit_rate_threshold
    }
    session = {
      client_timeout  = module.redis_session.performance_config.client_timeout
      tcp_keepalive   = module.redis_session.performance_config.tcp_keepalive
      defrag_settings = module.redis_session.performance_config.defrag_settings
    }
    queue = {
      additional_configs = module.redis_queue.performance_config.redis_configs
    }
  }
}
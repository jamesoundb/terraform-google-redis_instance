output "redis_instance" {
  description = "Redis instance details"
  value = {
    name           = module.redis_cost_optimized.id
    host           = module.redis_cost_optimized.host
    port           = module.redis_cost_optimized.port
    memory_size_gb = module.redis_cost_optimized.memory_size_gb
    tier           = local.env_config.tier
  }
}

output "cost_optimization" {
  description = "Cost optimization configuration and metrics"
  value = {
    environment          = var.environment
    is_ha_enabled        = local.env_config.ha_enabled
    autoscaling_enabled  = true
    scale_up_threshold   = var.memory_scale_up_threshold
    scale_down_threshold = var.memory_scale_down_threshold
  }
}

output "monitoring_dashboard" {
  description = "Cost optimization dashboard URL"
  value       = module.redis_cost_optimized.monitoring_resources
}
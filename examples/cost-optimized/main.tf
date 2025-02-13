provider "google" {
  project = var.project_id
  region  = var.region
}

# Define different Redis configurations based on environment
locals {
  environments = {
    dev = {
      tier           = "BASIC"
      memory_size_gb = 1
      ha_enabled     = false
    }
    staging = {
      tier           = "BASIC"
      memory_size_gb = 2
      ha_enabled     = false
    }
    prod = {
      tier           = "STANDARD_HA"
      memory_size_gb = 5
      ha_enabled     = true
    }
  }

  env_config = local.environments[var.environment]
}

# Deploy cost-optimized Redis instance
module "redis_cost_optimized" {
  source = "../../"

  project_id = var.project_id
  name       = "redis-${var.environment}"
  region     = var.region
  zone       = "${var.region}-a"

  # Use environment-specific configurations
  tier           = local.env_config.tier
  memory_size_gb = local.env_config.memory_size_gb
  secondary_zone = local.env_config.ha_enabled ? "${var.region}-b" : null

  authorized_network = var.vpc_network

  # Enable cost optimization features
  enable_cost_optimization = true
  enable_autoscaling       = true

  # Configure autoscaling thresholds
  memory_scale_up_threshold   = 0.8
  memory_scale_down_threshold = 0.4

  # Optimize persistence settings based on environment
  persistence_enabled = var.environment == "prod"
  persistence_mode    = "RDB"
  rdb_snapshot_period = var.environment == "prod" ? "6h" : "24h"

  # Configure maintenance window for off-peak hours
  maintenance_window_day     = 7 # Sunday
  maintenance_window_hour    = 3 # 3 AM
  maintenance_window_minutes = 0

  # Set environment-specific labels
  labels = {
    environment    = var.environment
    cost_optimized = "true"
    managed_by     = "terraform"
  }

  # Configure monitoring
  alert_notification_channels = var.alert_channels
}

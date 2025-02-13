module "redis_ha" {
  source = "../../"

  project_id         = "my-project-id"
  name               = "redis-ha"
  region             = "us-central1"
  zone               = "us-central1-a"
  secondary_zone     = "us-central1-b"
  memory_size_gb     = 5
  tier               = "STANDARD_HA"
  authorized_network = "projects/my-project-id/global/networks/default"

  # Optional configurations
  redis_version = "REDIS_6_X"
  display_name  = "HA Redis Instance"
  auth_enabled  = true

  # Labels for resource management
  labels = {
    environment = "prod"
    managed_by  = "terraform"
    ha_enabled  = "true"
  }

  # Maintenance window configuration
  maintenance_window_day     = 2 # Tuesday
  maintenance_window_hour    = 4 # 4 AM
  maintenance_window_minutes = 30

  # Enable persistence with RDB snapshots
  persistence_enabled = true
  persistence_mode    = "RDB"
  rdb_snapshot_period = "24h"
}

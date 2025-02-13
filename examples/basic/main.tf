module "redis_basic" {
  source = "../../"

  project_id         = "my-project-id"
  name              = "redis-basic"
  region            = "us-central1"
  zone              = "us-central1-a"
  memory_size_gb    = 1
  tier              = "BASIC"
  authorized_network = "projects/my-project-id/global/networks/default"

  # Optional configurations
  redis_version     = "REDIS_6_X"
  display_name      = "Basic Redis Instance"
  auth_enabled      = true
  
  # Labels for resource management
  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }

  # Maintenance window configuration
  maintenance_window_day     = 1  # Monday
  maintenance_window_hour    = 3  # 3 AM
  maintenance_window_minutes = 0

  # Disable persistence for basic instance
  persistence_enabled = false
}
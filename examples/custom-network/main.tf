# Create VPC Network
resource "google_compute_network" "redis_network" {
  name                    = "redis-network"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "redis_subnet" {
  name          = "redis-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.redis_network.id
}

# Create Redis instance
module "redis_custom_network" {
  source = "../../"

  project_id         = var.project_id
  name              = "redis-custom-net"
  region            = var.region
  zone              = "${var.region}-a"
  secondary_zone    = "${var.region}-b"
  memory_size_gb    = 5
  tier              = "STANDARD_HA"
  
  # Connect to custom VPC
  authorized_network = google_compute_network.redis_network.id
  reserved_ip_range = "10.0.1.0/28"

  # Enhanced security settings
  auth_enabled      = true
  redis_version     = "REDIS_6_X"
  
  # Production-grade configurations
  labels = {
    environment = "prod"
    managed_by  = "terraform"
    network     = "custom"
  }

  persistence_enabled    = true
  persistence_mode      = "RDB"
  rdb_snapshot_period   = "6h"

  maintenance_window_day     = 7  # Sunday
  maintenance_window_hour    = 2  # 2 AM
  maintenance_window_minutes = 0
}
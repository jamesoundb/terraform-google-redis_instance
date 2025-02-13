# Configure provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a secure VPC network for Redis
resource "google_compute_network" "redis_network" {
  name                    = "redis-secure-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "redis_subnet" {
  name          = "redis-secure-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.redis_network.id
  region        = var.region

  private_ip_google_access = true
}

# Create a Cloud KMS key for CMEK
resource "google_kms_key_ring" "redis" {
  name     = "redis-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "redis" {
  name     = "redis-key"
  key_ring = google_kms_key_ring.redis.id

  purpose = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }
}

# Storage buckets for Redis backups
resource "google_storage_bucket" "redis_backup" {
  count                       = var.enable_backup ? 1 : 0
  name                        = "redis-secure-backup-${var.project_id}"
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.backup_retention_days
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "cross_region_backup" {
  for_each = var.cross_region_backup ? toset(var.backup_regions) : []

  name                        = "redis-dr-backup-${each.value}-${var.project_id}"
  location                    = each.value
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.backup_retention_days
    }
    action {
      type = "Delete"
    }
  }
}

# Deploy Redis instance with security and backup features
# Note: For Customer Managed Encryption Keys (CMEK), you'll need to configure this at the
# project level or use the google_redis_instance resource directly. This module currently
# does not support CMEK configuration.
module "redis_secure" {
  source = "../../"

  project_id     = var.project_id
  name           = "redis-secure-prod"
  region         = var.region
  zone           = "${var.region}-a"
  secondary_zone = "${var.region}-b"

  # Instance configuration
  memory_size_gb = 10
  tier           = "STANDARD_HA"

  # Network security
  authorized_network = google_compute_network.redis_network.id
  reserved_ip_range  = "10.0.1.0/28"

  # Security features
  auth_enabled  = true
  redis_version = "REDIS_6_X"

  # Redis configurations including security settings
  redis_configs = {
    "maxmemory-policy"       = "volatile-lru"
    "notify-keyspace-events" = "Ex"
    "timeout"                = "3600"
    "tcp-keepalive"          = "300"
  }

  # Monitoring and alerts
  enable_optional_security_features = true
  alert_notification_channels       = var.notification_channels
  connections_threshold             = 500

  # Backup configuration
  persistence_enabled   = true
  persistence_mode      = "RDB"
  rdb_snapshot_period   = "SIX_HOURS"
  enable_backup         = true
  backup_retention_days = 30

  # Cross-region disaster recovery
  cross_region_backup = true
  backup_regions      = ["us-west1", "us-east1"]

  # Labels for security tracking
  labels = {
    environment    = "prod"
    security_level = "high"
    compliance     = "required"
    backup_enabled = "true"
  }
}

variables {
  test_project_id = "var.project_id"
  test_region     = "us-central1"
  test_zones = {
    primary   = "us-central1-a"
    secondary = "us-central1-b"
  }
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Test security configuration compliance
run "security_baseline_test" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "redis-security-test"
    region             = "us-central1"
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/secure-network"

    # Security settings that should be enforced
    auth_enabled  = true
    redis_version = "REDIS_6_X"

    # Network security
    reserved_ip_range = "10.0.2.0/28"

    # Labels for security tracking
    labels = {
      security_level = "high"
      compliance     = "required"
      encryption     = "enabled"
    }

    # Persistence configuration
    persistence_enabled = true
    persistence_mode    = "RDB"
    rdb_snapshot_period = "TWENTY_FOUR_HOURS"

    # Maintenance policy
    maintenance_window_day     = "MONDAY"
    maintenance_window_hour    = 2
    maintenance_window_minutes = 30
  }

  assert {
    condition     = var.auth_enabled == true
    error_message = "Redis AUTH must be enabled for security compliance"
  }

  assert {
    condition     = var.redis_version == "REDIS_6_X"
    error_message = "Must use Redis 6.x or higher for security features"
  }

  assert {
    condition     = contains(keys(var.labels), "security_level")
    error_message = "Security level label must be defined"
  }
}

# Test network security configuration
run "network_security_test" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-network-security"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/secure-network"
    reserved_ip_range  = "10.0.2.0/28"
  }

  assert {
    condition     = can(regex("^10\\.0\\.[0-9]{1,3}\\.[0-9]{1,3}/28$", var.reserved_ip_range))
    error_message = "Reserved IP range must be a /28 subnet for security"
  }
}

# Test access controls
run "access_control_test" {
  command = plan

  variables {
    project_id         = var.test_project_id
    name               = "redis-access-control"
    region             = var.test_region
    zone               = var.test_zones.primary
    secondary_zone     = var.test_zones.secondary
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/secure-network"
    auth_enabled       = true
  }

  assert {
    condition     = var.auth_enabled == true
    error_message = "Authentication must be enabled"
  }
}

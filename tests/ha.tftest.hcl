variables {
  name                = "test-ha-redis"
  project_id          = "test-project"
  tier                = "STANDARD_HA"
  region              = "us-central1"
  zone                = "us-central1-a"
  secondary_zone      = "us-central1-b"
  memory_size_gb      = 5
  persistence_enabled = true
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "ha_redis_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis-ha"
    region            = "us-central1"
    zone              = "us-central1-a"
    secondary_zone    = "us-central1-b"
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
  }

  assert {
    condition     = google_redis_instance.cache[0].tier == "STANDARD_HA"
    error_message = "Redis instance is not configured for HA"
  }

  assert {
    condition     = google_redis_instance.cache[0].memory_size_gb >= 5
    error_message = "Redis HA instance should have at least 5GB memory"
  }

  assert {
    condition     = google_redis_instance.cache[0].persistence_config[0].persistence_mode == "RDB"
    error_message = "Redis persistence should be enabled for HA instances"
  }
}

run "ha_redis_zones_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "test-redis-ha"
    region            = "us-central1"
    zone              = "us-central1-a"
    secondary_zone    = "us-central1-a"  # Same as primary zone
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
  }

  expect_failures = [
    google_redis_instance.cache # Expect the resource precondition to fail
  ]
}

run "ha_redis_persistence_validation" {
  command = plan

  variables {
    project_id           = var.project_id
    name                = "test-redis-ha"
    region              = "us-central1"
    zone                = "us-central1-a"
    secondary_zone      = "us-central1-b"
    memory_size_gb      = 5
    tier                = "STANDARD_HA"
    authorized_network   = "projects/${var.project_id}/global/networks/default"
    persistence_enabled  = true
    persistence_mode    = "RDB"
    rdb_snapshot_period = "TWENTY_FOUR_HOURS"
  }

  assert {
    condition     = contains(["ONE_HOUR", "SIX_HOURS", "TWELVE_HOURS", "TWENTY_FOUR_HOURS"], var.rdb_snapshot_period)
    error_message = "RDB snapshot period must be one of: ONE_HOUR, SIX_HOURS, TWELVE_HOURS, TWENTY_FOUR_HOURS"
  }
}

run "ha_redis_maintenance_window" {
  command = plan

  variables {
    project_id                 = var.project_id
    name                      = "test-redis-ha"
    region                    = "us-central1"
    zone                      = "us-central1-a"
    secondary_zone            = "us-central1-b"
    memory_size_gb            = 5
    tier                      = "STANDARD_HA"
    authorized_network        = "projects/${var.project_id}/global/networks/default"
    maintenance_window_day    = "SUNDAY"
    maintenance_window_hour   = 23
    maintenance_window_minutes = 30
  }

  assert {
    condition     = contains(["DAY_OF_WEEK_UNSPECIFIED", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance_window_day)
    error_message = "Maintenance window day must be a valid day of week string"
  }

  assert {
    condition     = var.maintenance_window_hour >= 0 && var.maintenance_window_hour <= 23
    error_message = "Maintenance window hour should be between 0 and 23"
  }

  assert {
    condition     = var.maintenance_window_minutes >= 0 && var.maintenance_window_minutes <= 59
    error_message = "Maintenance window minutes should be between 0 and 59"
  }
}
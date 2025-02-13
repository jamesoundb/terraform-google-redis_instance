provider "google" {
  project = var.project_id
  region  = "us-central1"
}

variables {
  project_id = "test-project-id"
}

run "backup_configuration_test" {
  command = plan

  variables {
    project_id            = var.project_id
    name                  = "redis-backup-test"
    region                = "us-central1"
    zone                  = "us-central1-a"
    secondary_zone        = "us-central1-b"
    memory_size_gb        = 5
    tier                  = "STANDARD_HA"
    authorized_network    = "projects/${var.project_id}/global/networks/default"
    persistence_enabled   = true
    persistence_mode      = "RDB"
    enable_backup         = true
    backup_retention_days = 30
  }

  assert {
    condition     = var.persistence_enabled == true
    error_message = "Persistence must be enabled for backups"
  }

  assert {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365"
  }

  assert {
    condition     = var.persistence_mode == "RDB"
    error_message = "Persistence mode must be RDB for backups"
  }
}

run "cross_region_backup_test" {
  command = plan

  variables {
    project_id          = var.project_id
    name                = "redis-dr-test"
    region              = "us-central1"
    zone                = "us-central1-a"
    secondary_zone      = "us-central1-b"
    memory_size_gb      = 5
    tier                = "STANDARD_HA"
    authorized_network  = "projects/${var.project_id}/global/networks/default"
    persistence_enabled = true
    persistence_mode    = "RDB"
    enable_backup       = true
    cross_region_backup = true
    backup_regions      = ["us-west1", "us-east1"]
  }

  assert {
    condition     = length(var.backup_regions) <= 3
    error_message = "Maximum of 3 backup regions allowed"
  }

  assert {
    condition     = !contains(var.backup_regions, var.region)
    error_message = "Backup regions should be different from primary region"
  }

  assert {
    condition     = var.cross_region_backup == true
    error_message = "Cross-region backup should be enabled"
  }
}

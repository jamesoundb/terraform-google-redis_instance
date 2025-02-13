locals {
  backup_enabled = var.persistence_enabled && var.enable_backup
  enable_dr      = var.cross_region_backup && length(var.backup_regions) > 0

  backup_buckets = local.enable_dr ? toset(var.backup_regions) : []
}

resource "google_storage_bucket" "backup_bucket" {
  count = var.persistence_enabled ? 1 : 0

  name          = "${var.name}-redis-backup"
  location      = var.backup_region != null ? var.backup_region : var.region
  force_destroy = var.force_destroy_backup
  project       = var.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = var.cross_region_backup
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

resource "google_storage_bucket_iam_member" "redis_backup_writer" {
  count  = var.persistence_enabled ? 1 : 0
  bucket = google_storage_bucket.backup_bucket[0].name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_redis_instance.cache[0].persistence_iam_identity}"

  condition {
    title       = "backup_access"
    description = "Grants Redis service account access to backup bucket"
    expression  = "resource.name.startsWith(\"${google_storage_bucket.backup_bucket[0].name}\")"
  }
}

resource "google_storage_bucket_iam_binding" "replication_binding" {
  count  = var.persistence_enabled ? 1 : 0
  bucket = google_storage_bucket.backup_bucket[0].name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_redis_instance.cache[0].persistence_iam_identity}"
  ]
}

resource "google_monitoring_alert_policy" "backup_failure" {
  count        = var.persistence_enabled ? 1 : 0
  display_name = "Redis Backup Failures"
  combiner     = "OR"
  conditions {
    display_name = "Redis backup failures"
    condition_threshold {
      filter          = "resource.type=\"redis_instance\" AND resource.labels.instance_id=\"${google_redis_instance.cache[0].name}\" AND metric.type=\"redis.googleapis.com/persistence/backup_failures\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0
    }
  }

  notification_channels = var.notification_channels
  alert_strategy {
    auto_close = "604800s"
  }
}

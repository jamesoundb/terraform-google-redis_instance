locals {
  base_roles = [
    "roles/redis.viewer",
    "roles/monitoring.viewer"
  ]

  admin_roles = [
    "roles/redis.admin",
    "roles/monitoring.admin"
  ]

  service_roles = [
    "roles/redis.viewer",
    "roles/monitoring.viewer",
    "roles/cloudtrace.user"
  ]
}

resource "google_project_iam_custom_role" "redis_operator" {
  count       = var.create_custom_roles ? 1 : 0
  project     = var.project_id
  role_id     = "redis_operator_${replace(lower(var.name), "-", "_")}"
  title       = "Redis Operator for ${var.name}"
  description = "Custom role for Redis operations with limited permissions"
  permissions = [
    "redis.instances.get",
    "redis.instances.list",
    "redis.locations.get",
    "redis.locations.list",
    "redis.operations.get",
    "redis.operations.list",
    "monitoring.timeSeries.list",
    "monitoring.metricDescriptors.list"
  ]
}

resource "google_service_account" "redis_service_account" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = substr("sa-rd-${var.name}", 0, 30) # Truncate to 30 chars max
  display_name = "Service Account for Redis instance ${var.name}"
  description  = "Manages access to Redis instance ${var.name}"
}

resource "google_project_iam_member" "redis_service_account_roles" {
  for_each = var.create_service_account ? toset(local.service_roles) : []

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.redis_service_account[0].email}"
}

resource "google_project_iam_member" "redis_admins" {
  for_each = toset(var.admin_members)

  project = var.project_id
  role    = "roles/redis.admin"
  member  = each.key
}

resource "google_project_iam_member" "redis_viewers" {
  for_each = toset(var.viewer_members)

  project = var.project_id
  role    = "roles/redis.viewer"
  member  = each.key
}

# IAM for monitoring access
resource "google_project_iam_member" "monitoring_access" {
  for_each = toset(concat(var.admin_members, var.viewer_members))

  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = each.key
}

# VPC Service Controls (if enabled)
resource "google_access_context_manager_service_perimeter" "redis_perimeter" {
  count          = var.enable_vpc_sc ? 1 : 0
  parent         = "accessPolicies/${var.access_policy_id}"
  name           = "accessPolicies/${var.access_policy_id}/servicePerimeters/redis_${var.name}"
  title          = "Redis ${var.name} Perimeter"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
    restricted_services = [
      "redis.googleapis.com",
      "monitoring.googleapis.com"
    ]

    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = ["redis.googleapis.com"]
    }

    access_levels = var.vpc_sc_access_levels
  }
}

variables {
  project_id = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "service_account_creation" {
  command = plan

  variables {
    project_id             = var.project_id
    name                   = "test-redis-iam"
    region                 = "us-central1"
    zone                   = "us-central1-a"
    secondary_zone         = "us-central1-b"
    memory_size_gb         = 5
    tier                   = "STANDARD_HA"
    authorized_network     = "projects/${var.project_id}/global/networks/default"
    create_service_account = true
  }

  assert {
    condition     = var.create_service_account
    error_message = "Service account creation should be enabled"
  }
}

run "custom_role_validation" {
  command = plan

  variables {
    project_id          = var.project_id
    name                = "test-redis-roles"
    region              = "us-central1"
    zone                = "us-central1-a"
    secondary_zone      = "us-central1-b"
    memory_size_gb      = 5
    tier                = "STANDARD_HA"
    authorized_network  = "projects/${var.project_id}/global/networks/default"
    create_custom_roles = true
    admin_members       = ["user:test-admin@example.com"]
    viewer_members      = ["group:test-viewers@example.com"]
  }

  assert {
    condition     = length(var.admin_members) > 0
    error_message = "Admin members should be specified"
  }

  assert {
    condition     = alltrue([for m in var.admin_members : can(regex("^(user|group|serviceAccount):.+@.+", m))])
    error_message = "Invalid admin member format"
  }

  assert {
    condition     = alltrue([for m in var.viewer_members : can(regex("^(user|group|serviceAccount):.+@.+", m))])
    error_message = "Invalid viewer member format"
  }
}

run "vpc_sc_validation" {
  command = plan

  variables {
    project_id           = var.project_id
    name                 = "test-redis-vpc-sc"
    region               = "us-central1"
    zone                 = "us-central1-a"
    secondary_zone       = "us-central1-b"
    memory_size_gb       = 5
    tier                 = "STANDARD_HA"
    authorized_network   = "projects/${var.project_id}/global/networks/default"
    enable_vpc_sc        = true
    access_policy_id     = "123456789"
    vpc_sc_access_levels = ["accessPolicies/123456789/accessLevels/redis_access"]
  }

  assert {
    condition     = var.enable_vpc_sc == true
    error_message = "VPC Service Controls should be enabled"
  }

  assert {
    condition     = var.access_policy_id != null
    error_message = "Access Policy ID must be provided when VPC SC is enabled"
  }

  assert {
    condition     = length(var.vpc_sc_access_levels) > 0
    error_message = "VPC SC access levels must be specified"
  }
}

run "combined_security_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-redis-security"
    region             = "us-central1"
    zone               = "us-central1-a"
    secondary_zone     = "us-central1-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"

    # IAM configuration
    create_service_account = true
    create_custom_roles    = true
    admin_members          = ["user:admin@example.com"]
    viewer_members         = ["group:viewers@example.com"]

    # VPC SC configuration
    enable_vpc_sc        = true
    access_policy_id     = "123456789"
    vpc_sc_access_levels = ["accessPolicies/123456789/accessLevels/redis_access"]

    # Security settings
    auth_enabled  = true
    redis_version = "REDIS_6_X"
  }

  assert {
    condition     = var.auth_enabled && var.create_service_account && var.create_custom_roles
    error_message = "All security features should be enabled for comprehensive security"
  }
}

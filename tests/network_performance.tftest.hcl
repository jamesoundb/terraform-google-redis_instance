variables {
  project_id = "test-project-id"
  region = "us-central1"
  zones = {
    primary = "us-central1-a"
    secondary = "us-central1-b"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

run "network_monitoring_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "redis-network-test"
    region            = var.region
    zone              = var.zones.primary
    secondary_zone    = var.zones.secondary
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    
    enable_network_monitoring = true
    max_connections_threshold = 1000
    network_latency_threshold_ms = 5
    connection_rejection_threshold = 10
    
    create_firewall_rules = true
    allowed_ip_ranges = ["10.0.0.0/8", "172.16.0.0/12"]
    allowed_source_tags = ["redis-client"]
    
    persistence_enabled = true
    persistence_mode = "RDB"
    rdb_snapshot_period = "TWENTY_FOUR_HOURS"
    maintenance_window_day = "MONDAY"
    maintenance_window_hour = 2
    maintenance_window_minutes = 30
  }

  assert {
    condition     = var.enable_network_monitoring
    error_message = "Network monitoring should be enabled"
  }

  assert {
    condition     = alltrue([for ip in var.allowed_ip_ranges : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", ip))])
    error_message = "Invalid IP CIDR ranges provided"
  }
}

run "network_thresholds_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "redis-network-thresholds"
    region            = var.region
    zone              = var.zones.primary
    secondary_zone    = var.zones.secondary
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    
    max_connections_threshold = 2000
    network_latency_threshold_ms = 10
    connection_rejection_threshold = 5
  }

  assert {
    condition     = var.max_connections_threshold > 0 && var.network_latency_threshold_ms > 0
    error_message = "Invalid threshold values"
  }

  assert {
    condition     = var.connection_rejection_threshold >= 0
    error_message = "Connection rejection threshold must be non-negative"
  }
}

run "firewall_rules_validation" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "redis-firewall-test"
    region            = var.region
    zone              = var.zones.primary
    secondary_zone    = var.zones.secondary
    memory_size_gb    = 5
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    
    create_firewall_rules = true
    allowed_source_tags = ["app-server", "cache-client"]
    allowed_ip_ranges = ["10.0.0.0/8"]
  }

  assert {
    condition     = length(var.allowed_source_tags) > 0
    error_message = "Source tags must be specified when creating firewall rules"
  }

  assert {
    condition     = length(var.allowed_ip_ranges) > 0
    error_message = "Allowed IP ranges must be specified"
  }
}

run "ha_network_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name              = "redis-ha-network"
    region            = var.region
    zone              = var.zones.primary
    secondary_zone    = var.zones.secondary
    memory_size_gb    = 10
    tier              = "STANDARD_HA"
    authorized_network = "projects/${var.project_id}/global/networks/default"
    
    enable_network_monitoring = true
    max_connections_threshold = 5000
    network_latency_threshold_ms = 3
    connection_rejection_threshold = 20
  }

  assert {
    condition     = var.tier == "STANDARD_HA" && var.enable_network_monitoring
    error_message = "HA configuration requires network monitoring"
  }

  assert {
    condition     = var.max_connections_threshold >= 1000
    error_message = "HA setup requires higher connection threshold"
  }

  assert {
    condition     = var.network_latency_threshold_ms <= 5
    error_message = "HA setup requires stricter latency thresholds"
  }
}
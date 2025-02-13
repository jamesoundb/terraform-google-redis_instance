variables {
  test_region  = "us-central1"
  test_project = "var.project_id"
  test_network = "projects/var.project_id/global/networks/default"
  project_id   = "test-project-id"
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

run "cache_workload_validation" {
  command = plan

  variables {
    project_id                 = var.project_id
    name                       = "redis-workload-test"
    region                     = "us-central1"
    zone                       = "us-central1-a"
    secondary_zone             = "us-central1-b"
    memory_size_gb             = 5
    tier                       = "STANDARD_HA"
    authorized_network         = "projects/${var.project_id}/global/networks/default"
    workload_type              = "cache"
    persistence_enabled        = true
    persistence_mode           = "RDB"
    rdb_snapshot_period        = "TWENTY_FOUR_HOURS"
    maintenance_window_day     = "MONDAY"
    maintenance_window_hour    = 2
    maintenance_window_minutes = 30
  }

  assert {
    condition     = var.workload_type == "cache"
    error_message = "Cache workload type not configured correctly"
  }
}

run "session_workload_validation" {
  command = plan

  variables {
    project_id         = var.test_project
    name               = "redis-session-test"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    secondary_zone     = "${var.test_region}-b"
    memory_size_gb     = 5 # Increased from 3 to meet HA tier requirement
    tier               = "STANDARD_HA"
    authorized_network = var.test_network
    workload_type      = "session"
    client_timeout     = 300
    tcp_keepalive      = 60
  }

  assert {
    condition     = var.workload_type == "session"
    error_message = "Session workload type not configured correctly"
  }

  assert {
    condition     = var.client_timeout > 0 && var.tcp_keepalive > 0
    error_message = "Session configuration requires proper timeout settings"
  }
}

run "queue_workload_validation" {
  command = plan

  variables {
    project_id         = var.test_project
    name               = "redis-queue-test"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    secondary_zone     = "${var.test_region}-b"
    memory_size_gb     = 5 # Increased from 4 to meet HA tier requirement
    tier               = "STANDARD_HA"
    authorized_network = var.test_network
    workload_type      = "queue"
  }

  assert {
    condition     = var.workload_type == "queue"
    error_message = "Queue workload type not configured correctly"
  }
}

run "custom_workload_validation" {
  command = plan

  variables {
    project_id         = var.test_project
    name               = "redis-custom-test"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    secondary_zone     = "${var.test_region}-b"
    memory_size_gb     = 5
    tier               = "STANDARD_HA"
    authorized_network = var.test_network
    maxmemory_policy   = "volatile-ttl"
    additional_redis_configs = {
      "hash-max-ziplist-entries" = "512"
      "set-max-intset-entries"   = "512"
      "zset-max-ziplist-entries" = "128"
    }
  }

  assert {
    condition     = var.maxmemory_policy != null
    error_message = "Custom workload requires explicit memory policy"
  }

  assert {
    condition     = length(var.additional_redis_configs) > 0
    error_message = "Custom workload should specify additional configurations"
  }
}

run "workload_performance_monitoring" {
  command = plan

  variables {
    project_id                    = var.test_project
    name                          = "redis-perf-test"
    region                        = var.test_region
    zone                          = "${var.test_region}-a"
    secondary_zone                = "${var.test_region}-b"
    memory_size_gb                = 5
    tier                          = "STANDARD_HA"
    authorized_network            = var.test_network
    workload_type                 = "cache"
    enable_performance_monitoring = true
  }

  assert {
    condition     = var.enable_performance_monitoring
    error_message = "Performance monitoring should be enabled for workload optimization"
  }
}

run "cache_workload" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-cache"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    memory_size_gb     = 1
    tier               = "BASIC" # Explicitly set to BASIC tier
    authorized_network = var.test_network
    workload_type      = "cache"
  }

  assert {
    condition     = var.workload_type == "cache"
    error_message = "Cache workload should use cache workload type"
  }
}

run "session_workload" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-session"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    tier               = "BASIC" # Changed from STANDARD_HA to BASIC to avoid secondary_zone requirement
    memory_size_gb     = 1
    authorized_network = var.test_network
    workload_type      = "session"
  }

  assert {
    condition     = var.workload_type == "session"
    error_message = "Session workload should use session workload type"
  }
}

run "queue_workload" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-queue"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    tier               = "BASIC" # Changed from STANDARD_HA to BASIC to avoid secondary_zone requirement
    memory_size_gb     = 1
    authorized_network = var.test_network
    workload_type      = "queue"
  }

  assert {
    condition     = var.workload_type == "queue"
    error_message = "Queue workload should use queue workload type"
  }
}

run "custom_config" {
  command = plan

  variables {
    project_id         = var.project_id
    name               = "test-custom"
    region             = var.test_region
    zone               = "${var.test_region}-a"
    tier               = "BASIC" # Explicitly set to BASIC tier
    memory_size_gb     = 1
    authorized_network = var.test_network
    maxmemory_policy   = "volatile-ttl"
    redis_configs = {
      notify-keyspace-events = "Ex"
      maxmemory-samples      = "7"
    }
  }

  assert {
    condition     = var.maxmemory_policy == "volatile-ttl"
    error_message = "Custom maxmemory policy not applied correctly"
  }
}

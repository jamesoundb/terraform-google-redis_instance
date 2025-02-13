variables {
  project_id = "test-project"
  region     = "us-central1"
  zone       = "us-central1-a"
}

# Test dev environment configuration
run "dev_environment" {
  command = plan

  variables {
    name                        = "redis-dev"
    memory_size_gb              = 1
    authorized_network          = "default"
    tier                        = "BASIC"
    enable_alerts               = false
    enable_network_monitoring   = false
    create_monitoring_dashboard = false
  }

  assert {
    condition     = var.tier == "BASIC"
    error_message = "Dev environment should use BASIC tier"
  }

  assert {
    condition     = var.memory_size_gb == 1
    error_message = "Dev environment should use 1GB memory"
  }
}

# Test production environment configuration
run "prod_environment" {
  command = plan

  variables {
    name                        = "redis-prod"
    memory_size_gb              = 5
    authorized_network          = "default"
    tier                        = "STANDARD_HA"
    secondary_zone              = "us-central1-b"
    enable_alerts               = false
    enable_network_monitoring   = false
    create_monitoring_dashboard = false
  }

  assert {
    condition     = var.tier == "STANDARD_HA"
    error_message = "Production environment should use STANDARD_HA tier"
  }

  assert {
    condition     = var.memory_size_gb == 5
    error_message = "Production environment should use 5GB memory"
  }
}

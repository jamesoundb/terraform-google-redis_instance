# Testing Guide for GCP Redis Module

This document describes the testing strategy for the GCP Redis module which focuses on environment configurations and workload patterns.

## Test Categories

### Environment Tests
- `environment_dev.tftest.hcl`: Development environment configuration
- `environment_staging.tftest.hcl`: Staging environment configuration
- `environment_prod.tftest.hcl`: Production environment configuration

### Workload Pattern Tests
- `workload_cache.tftest.hcl`: Cache workload pattern validation
- `workload_session.tftest.hcl`: Session storage pattern validation
- `workload_queue.tftest.hcl`: Queue workload pattern validation

### Configuration Tests
- `maintenance_window.tftest.hcl`: Maintenance window settings
- `persistence.tftest.hcl`: Redis persistence configuration
- `network.tftest.hcl`: Network configuration validation

## Test Setup

### Prerequisites
- Terraform 1.5 or later
- Google Cloud provider

### Default Test Values
```hcl
variables {
  project_id = "test-project-id"
  region     = "us-central1"
  zone       = "us-central1-a"
}
```

## Running Tests

### Basic Test Execution
```bash
# Run all tests
terraform test

# Run specific test categories
terraform test -filter="environment"
terraform test -filter="workload"
terraform test -filter="config"
```

### Testing with Real Project
```bash
# Test with actual GCP project
terraform test -var="project_id=your-project-id"
```

## Test Coverage

### Environment Configuration Tests
- Dev environment settings
  - BASIC tier
  - 1GB memory
  - No HA
- Staging environment settings
  - BASIC tier
  - 2GB memory
  - No HA
- Production environment settings
  - STANDARD_HA tier
  - 5GB memory
  - HA enabled

### Workload Pattern Tests
- Cache pattern
  - allkeys-lru policy
  - Expiry notifications
  - 10 memory samples
- Session pattern
  - volatile-lru policy
  - Key notifications
  - 5 memory samples
- Queue pattern
  - noeviction policy
  - Key/list notifications
  - 3 memory samples

### Configuration Tests
- Maintenance window validation
- Persistence settings
- Network configuration
- Resource naming
- Variable validation

## Writing New Tests

### Test File Template
```hcl
variables {
  project_id = "test-project-id"
  region     = "us-central1"
  zone       = "us-central1-a"
}

run "test_name" {
  command = plan

  assert {
    condition     = output.memory_size_gb == expected_value
    error_message = "Memory size does not match expected value"
  }
}
```

## Best Practices

1. Test each environment configuration
2. Validate workload pattern settings
3. Test maintenance window configurations
4. Verify persistence settings
5. Check network configurations

## Troubleshooting

### Common Issues
1. Invalid environment names
2. Incorrect workload pattern settings
3. Maintenance window configuration errors

### Debug Output
```bash
TF_LOG=DEBUG terraform test

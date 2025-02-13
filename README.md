# Google Cloud Memorystore Redis Terraform Module

This Terraform module deploys Google Cloud Memorystore Redis instances with optimized configurations for different workload patterns and environments.

## Features

### Core Features
- Environment-based configurations (dev, staging, prod)
- Workload pattern optimization (cache, session, queue)
- Basic and HA tier support
- Configurable maintenance windows
- Redis persistence options

### Workload Patterns
- **Cache**: Optimized for general caching with LRU eviction
- **Session**: Configured for session storage with no eviction
- **Queue**: Optimized for message queuing workloads

### Cost Optimization
- Environment-specific sizing
- Automatic scaling capabilities
- Memory utilization thresholds
- Cost-optimized maintenance windows

## Usage

### Basic Usage with Workload Pattern
```hcl
module "redis" {
  source = "../../"

  project_id         = "your-project-id"
  name              = "redis-cache"
  region            = "us-central1"
  zone              = "us-central1-a"
  memory_size_gb    = 5
  tier              = "STANDARD_HA"
  authorized_network = "projects/your-project/global/networks/your-vpc"
  
  # Workload-specific optimization
  workload_type     = "cache"  # Options: cache, session, queue
}
```

### Environment-based Configuration
```hcl
module "redis" {
  source = "../../"

  project_id = "your-project-id"
  name       = "redis-${var.environment}"
  region     = "us-central1"
  zone       = "us-central1-a"

  # Environment will automatically configure appropriate settings
  environment = "dev"  # Options: dev, staging, prod

  authorized_network = "your-vpc-network"

  # Optional: Override default environment settings
  enable_cost_optimization = true
  enable_autoscaling      = true
}
```

### Default Environment Configurations
```hcl
environments = {
  dev = {
    tier           = "BASIC"
    memory_size_gb = 1
    ha_enabled     = false
  }
  staging = {
    tier           = "BASIC"
    memory_size_gb = 2
    ha_enabled     = false
  }
  prod = {
    tier           = "STANDARD_HA"
    memory_size_gb = 5
    ha_enabled     = true
  }
}
```

### Workload Pattern Configurations
```hcl
workload_patterns = {
  cache = {
    maxmemory_policy       = "allkeys-lru"
    notify_keyspace_events = "Ex"
    max_memory_samples     = 10
  }
  session = {
    maxmemory_policy       = "volatile-lru"
    notify_keyspace_events = "Kx"
    max_memory_samples     = 5
  }
  queue = {
    maxmemory_policy       = "noeviction"
    notify_keyspace_events = "Klg"
    max_memory_samples     = 3
  }
}
```

## Required Variables
- `project_id`: GCP project ID
- `name`: Redis instance name
- `region`: Deployment region
- `zone`: Primary zone
- `authorized_network`: VPC network name

## Optional Variables
- `workload_type`: Workload pattern (cache/session/queue)
- `environment`: Environment name (dev/staging/prod)
- `tier`: Service tier (BASIC/STANDARD_HA)
- `memory_size_gb`: Redis memory size in GB
- `secondary_zone`: Zone for HA replica
- `maintenance_window_day`: Day for maintenance
- `maintenance_window_hour`: Hour for maintenance
- `maintenance_window_minutes`: Minutes for maintenance

See `variables.tf` for all available variables and their descriptions.

## Outputs
- `instance_id`: The Redis instance ID
- `host`: The IP address of the Redis instance
- `port`: The port number of the Redis instance

## Testing

Run the test suite:
```bash
terraform test
```

For development testing with a real project:
```bash
terraform test -var="project_id=your-project-id"
```

## Best Practices

### Workload Selection
1. Use appropriate workload pattern for your use case:
   - `cache`: For general caching with LRU eviction
   - `session`: For session storage requiring persistence
   - `queue`: For message queue workloads

### Environment Configuration
1. Use environment-appropriate tiers:
   - `dev`: BASIC tier for development
   - `staging`: BASIC tier for testing
   - `prod`: STANDARD_HA for production

### Performance
1. Monitor memory utilization
2. Configure appropriate maintenance windows
3. Use workload-specific Redis configurations

## License

Apache 2.0 - See LICENSE for more information.
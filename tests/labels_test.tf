terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

module "redis_with_labels" {
  source = "../"

  project_id         = "test-project"
  name               = "test-redis"
  region             = "us-central1"
  zone               = "us-central1-a"
  tier               = "BASIC"
  authorized_network = "default"
  memory_size_gb     = 1
  labels = {
    environment = "test"
    managed_by  = "terraform"
  }
}

resource "test_assertions" "labels" {
  component = "labels"

  check "redis_instance_exists" {
    description = "Check if Redis instance is created (not using cluster mode)"
    condition   = length(module.redis_with_labels.redis_instance) > 0
  }

  equal "labels" {
    description = "Check if labels are set correctly"
    got         = module.redis_with_labels.redis_instance[0].labels
    want = {
      environment = "test"
      managed_by  = "terraform"
    }
  }

  equal "instance_name" {
    description = "Check if Redis instance name is set correctly"
    got         = module.redis_with_labels.redis_instance[0].name
    want        = "test-redis"
  }
}

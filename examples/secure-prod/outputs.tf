output "redis_instance" {
  description = "Redis instance details"
  value = {
    host = module.redis_secure.host
    port = module.redis_secure.port
  }
}

output "security_configuration" {
  description = "Security configuration details"
  value       = module.redis_secure.security_config
}

output "network_security" {
  description = "Network security configuration"
  value       = module.redis_secure.network_security
  sensitive   = true
}

output "monitoring_resources" {
  description = "Monitoring and alerting resources"
  value       = module.redis_secure.monitoring_resources
}

output "backup_buckets" {
  description = "Backup storage bucket information"
  value = {
    primary_bucket = google_storage_bucket.redis_backup[0].name
    dr_buckets     = values(google_storage_bucket.cross_region_backup)[*].name
  }
}

output "kms_key" {
  description = "KMS key used for encryption"
  value       = google_kms_crypto_key.redis.id
}
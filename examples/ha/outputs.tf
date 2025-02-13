output "redis_host" {
  description = "The IP address of the Redis instance"
  value       = module.redis_ha.host
}

output "redis_port" {
  description = "The port number of the Redis instance"
  value       = module.redis_ha.port
}

output "redis_id" {
  description = "The Redis instance ID"
  value       = module.redis_ha.id
}

output "auth_string" {
  description = "The Redis instance auth string"
  value       = module.redis_ha.auth_string
  sensitive   = true
}

output "current_location" {
  description = "The current zone where the Redis endpoint is placed"
  value       = module.redis_ha.current_location_id
}

output "persistence_iam_identity" {
  description = "Cloud Storage IAM identity for persistence"
  value       = module.redis_ha.persistence_iam_identity
}

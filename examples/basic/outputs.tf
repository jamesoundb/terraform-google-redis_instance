output "redis_host" {
  description = "The IP address of the Redis instance"
  value       = module.redis_basic.host
}

output "redis_port" {
  description = "The port number of the Redis instance"
  value       = module.redis_basic.port
}

output "redis_id" {
  description = "The Redis instance ID"
  value       = module.redis_basic.id
}

output "auth_string" {
  description = "The Redis instance auth string"
  value       = module.redis_basic.auth_string
  sensitive   = true
}
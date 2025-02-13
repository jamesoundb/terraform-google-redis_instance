output "redis_host" {
  description = "The IP address of the Redis instance"
  value       = module.redis_custom_network.host
}

output "redis_port" {
  description = "The port number of the Redis instance"
  value       = module.redis_custom_network.port
}

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.redis_network.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.redis_subnet.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.redis_network.name
}

output "auth_string" {
  description = "The Redis instance auth string"
  value       = module.redis_custom_network.auth_string
  sensitive   = true
}

output "persistence_iam_identity" {
  description = "Cloud Storage IAM identity for persistence"
  value       = module.redis_custom_network.persistence_iam_identity
}

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment (dev, staging, or prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "vpc_network" {
  description = "The VPC network to connect the Redis instance to"
  type        = string
}

variable "alert_channels" {
  description = "List of notification channel IDs for alerts"
  type        = list(string)
  default     = []
}

variable "memory_scale_up_threshold" {
  description = "Memory usage threshold for scaling up (between 0 and 1)"
  type        = number
  default     = 0.85
  validation {
    condition     = var.memory_scale_up_threshold > 0 && var.memory_scale_up_threshold <= 1
    error_message = "Scale up threshold must be between 0 and 1"
  }
}

variable "memory_scale_down_threshold" {
  description = "Memory usage threshold for scaling down (between 0 and 1)"
  type        = number
  default     = 0.4
  validation {
    condition     = var.memory_scale_down_threshold > 0 && var.memory_scale_down_threshold < 1
    error_message = "Scale down threshold must be between 0 and 1"
  }
}
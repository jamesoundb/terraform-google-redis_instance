variable "project_id" {
  description = "The ID of the project where this resource will be created"
  type        = string
}

variable "region" {
  description = "The region where Redis instances will be created"
  type        = string
  default     = "us-central1"
}

variable "vpc_network" {
  description = "The VPC network ID to connect Redis instances to"
  type        = string
}

variable "connection_monitoring" {
  description = "Enable connection monitoring for workload analysis"
  type        = bool
  default     = true
}

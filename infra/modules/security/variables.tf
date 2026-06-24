variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. myapp-dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create security groups in"
  type        = string
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 3000
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

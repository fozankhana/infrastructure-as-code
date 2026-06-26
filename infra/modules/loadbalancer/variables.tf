variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. myapp-dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create the target group in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to place the ALB in (one per AZ)"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID to attach to the ALB"
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

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener"
  type        = string
}

variable "access_log_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}

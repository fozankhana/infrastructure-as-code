variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. myapp-dev)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the ASG launches instances into"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID attached to each EC2 instance"
  type        = string
}

variable "instance_profile_arn" {
  description = "IAM instance profile ARN granting SSM and other permissions"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN the ASG registers instances with"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

variable "db_host" {
  description = "RDS endpoint hostname injected into the userdata script"
  type        = string
}

variable "app_version" {
  description = "Application version tag to deploy (e.g. v1.4.2 or latest)"
  type        = string
  default     = "latest"
}

variable "asg_min" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. myapp-dev)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to place the RDS instance in"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group ID to attach to the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage_gb" {
  description = "Allocated storage in GB (auto-scales up to 3x)"
  type        = number
  default     = 20
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}

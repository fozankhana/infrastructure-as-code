variable "name_prefix" {
  description = "Prefix applied to all resource names (e.g. myapp-dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of AZs to create subnets in"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ (saves cost in non-prod)"
  type        = bool
  default     = false
}

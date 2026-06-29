locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------------------------
# Networking — VPC, subnets, IGW, NAT gateways, route tables
# ---------------------------------------------------------------------------

module "networking" {
  source = "./modules/networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  # Single NAT gateway in dev/staging saves ~$100/month per extra AZ
  single_nat_gateway = var.environment != "prod"
}

# ---------------------------------------------------------------------------
# Security — security groups (ALB → App → DB) and EC2 IAM role
# ---------------------------------------------------------------------------

module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id
  app_port    = 3000
  environment = var.environment
}

# ---------------------------------------------------------------------------
# Load Balancer — ALB, target group, HTTP→HTTPS redirect, HTTPS listener
# ---------------------------------------------------------------------------

module "loadbalancer" {
  source = "./modules/loadbalancer"

  name_prefix         = local.name_prefix
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  alb_sg_id           = module.security.alb_sg_id
  app_port            = 3000
  environment         = var.environment
  acm_certificate_arn = var.acm_certificate_arn
  access_log_bucket   = var.log_bucket
}

# ---------------------------------------------------------------------------
# Database — RDS PostgreSQL 15 in private subnets
# ---------------------------------------------------------------------------

module "database" {
  source = "./modules/database"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.networking.private_subnet_ids
  db_sg_id           = module.security.db_sg_id

  db_name     = "appdb"
  db_username = "appuser"
  db_password = var.db_password

  db_instance_class = var.db_instance_class
  db_storage_gb     = var.environment == "prod" ? 100 : 20
  environment       = var.environment
}

# ---------------------------------------------------------------------------
# Compute — Launch Template, ASG, CPU scaling policy
# ---------------------------------------------------------------------------

module "compute" {
  source = "./modules/compute"

  name_prefix          = local.name_prefix
  private_subnet_ids   = module.networking.private_subnet_ids
  app_sg_id            = module.security.app_sg_id
  instance_profile_arn = module.security.ec2_instance_profile_arn
  target_group_arn     = module.loadbalancer.target_group_arn

  instance_type = var.instance_type
  environment   = var.environment
  db_host       = module.database.db_host
  app_version   = var.app_version

  # Scale settings differ by environment
  asg_min     = var.environment == "prod" ? 3 : 1
  asg_max     = var.environment == "prod" ? 10 : 3
  asg_desired = var.environment == "prod" ? 3 : 1
}

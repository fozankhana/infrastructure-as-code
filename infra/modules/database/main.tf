# Random suffix on the identifier so a destroy+recreate (blue/green) never
# collides with the previous instance name while it is still being deleted.
resource "random_id" "db_suffix" {
  byte_length = 4
}

# ---------------------------------------------------------------------------
# Subnet Group — place RDS in private subnets only
# ---------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.name_prefix}-db-subnet-group" }
}

# ---------------------------------------------------------------------------
# Parameter Group — PostgreSQL 15 tuning
# ---------------------------------------------------------------------------

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.name_prefix}-pg15"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  # Log any query that takes longer than 1 second
  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = { Name = "${var.name_prefix}-pg15" }
}

# ---------------------------------------------------------------------------
# RDS PostgreSQL 15 Instance
# ---------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-db-${random_id.db_suffix.hex}"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_storage_gb
  max_allocated_storage = var.db_storage_gb * 3 # autoscaling up to 3x initial size
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  # Multi-AZ only in prod — costs 2x but gives automatic failover
  multi_az = var.environment == "prod" ? true : false

  publicly_accessible = false

  # In prod: keep a final snapshot when the instance is destroyed
  skip_final_snapshot       = var.environment == "prod" ? false : true
  final_snapshot_identifier = var.environment == "prod" ? "${var.name_prefix}-db-final-snapshot" : null

  # Protect prod from accidental terraform destroy
  deletion_protection = var.environment == "prod" ? true : false

  # Automated backups
  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Performance Insights for query-level monitoring in prod
  performance_insights_enabled          = var.environment == "prod" ? true : false
  performance_insights_retention_period = var.environment == "prod" ? 7 : null

  # After first apply the password is managed externally (Secrets Manager etc.)
  # Ignore drift so Terraform doesn't reset it on every plan.
  lifecycle {
    ignore_changes = [password]
  }

  tags = { Name = "${var.name_prefix}-db" }
}

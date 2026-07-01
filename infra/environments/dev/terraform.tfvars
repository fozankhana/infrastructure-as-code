project_name = "myapp"
environment  = "dev"
aws_region   = "us-east-1"
owner_email  = "fozanblogger@gmail.com"

vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_type     = "t3.small"
db_instance_class = "db.t3.micro"
app_version       = "latest"

# Replace with the real ACM certificate ARN before deploying
acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"

# S3 bucket that must exist and allow ALB to write access logs
log_bucket = "myapp-dev-alb-logs"

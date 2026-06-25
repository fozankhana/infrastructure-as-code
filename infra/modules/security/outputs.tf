output "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security group ID for the application EC2 instances"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Security group ID for the RDS database"
  value       = aws_security_group.db.id
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile attached to EC2 instances"
  value       = aws_iam_instance_profile.ec2.arn
}

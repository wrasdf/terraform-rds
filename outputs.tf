output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds[0].address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.rds[0].arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds[0].endpoint
}

output "db_listener_endpoint" {
  description = "Specifies the listener connection endpoint for SQL Server Always On"
  value       = aws_db_instance.rds[0].listener_endpoint
}

output "db_instance_engine" {
  description = "The database engine"
  value       = aws_db_instance.rds[0].engine
}

output "db_instance_engine_version_actual" {
  description = "The running version of the database"
  value       = aws_db_instance.rds[0].engine_version_actual
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.rds[0].hosted_zone_id
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.rds[0].identifier
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = aws_db_instance.rds[0].resource_id
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.rds[0].db_name
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.rds[0].port
}

output "db_instance_cloudwatch_log_group" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = aws_cloudwatch_log_group.log[0].id
}

output "db_instance_security_group_id" {
  description = "Security group id of db instance."
  value       = aws_security_group.sg[0].id
}

output "db_instance_kms_key_id" {
  description = "KMS key id of db instance encryption."
  value       = aws_kms_key.key[0].id
}

output "db_instance_kms_key_arn" {
  description = "KMS key ARN of db instance encryption."
  value       = aws_kms_key.key[0].arn
}

output "db_option_group_id" {
  description = "The db option group id"
  value       = aws_db_option_group.option[0].id
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = aws_db_option_group.option[0].arn
}

output "db_parameter_group_id" {
  description = "The db parameter group id"
  value       = aws_db_parameter_group.parameter[0].id
}

output "db_parameter_group_arn" {
  description = "The ARN of the db parameter group"
  value       = aws_db_parameter_group.parameter[0].arn
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = aws_db_subnet_group.subnet[0].id
}

output "db_subnet_group_arn" {
  description = "The ARN of the db subnet group"
  value       = aws_db_subnet_group.subnet[0].arn
}

output "username_ssm_parameter_name" {
  description = "Name of the parameter"
  value       = aws_ssm_parameter.username[0].id
}

output "username_ssm_parameter_arn" {
  description = "The ARN of the parameter"
  value       = aws_ssm_parameter.username[0].arn
}

output "password_ssm_parameter_name" {
  description = "Name of the parameter"
  value       = aws_ssm_parameter.password[0].id
}

output "password_ssm_parameter_arn" {
  description = "The ARN of the parameter"
  value       = aws_ssm_parameter.password[0].arn
}

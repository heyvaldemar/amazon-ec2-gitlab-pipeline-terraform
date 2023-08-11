# Create an RDS instance
resource "aws_db_instance" "db_instance_1" {
  identifier     = var.rds_db_instance_1_id
  instance_class = var.rds_db_instance_1_class
  # availability_zone must be set only if multi_az option is not used
  # availability_zone         = "eu-west-1a"
  multi_az                  = var.rds_multi_az
  publicly_accessible       = var.rds_publicly_accessible
  customer_owned_ip_enabled = var.rds_customer_owned_ip_enabled

  engine                      = var.rds_engine
  engine_version              = var.rds_engine_version
  allow_major_version_upgrade = var.rds_allow_major_version_upgrade
  auto_minor_version_upgrade  = var.rds_auto_minor_version_upgrade
  apply_immediately           = var.rds_apply_immediately

  db_name                             = var.rds_db_1_name
  username                            = local.rds_db_credentials_1["ps_gitlab_username"]
  password                            = local.rds_db_credentials_1["ps_gitlab_password"]
  port                                = var.rds_db_1_port
  iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled

  allocated_storage     = var.rds_db_instance_1_allocated_storage
  max_allocated_storage = var.rds_db_instance_1_max_allocated_storage
  storage_type          = var.rds_storage_type
  storage_encrypted     = var.rds_storage_encrypted

  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_kms_key_id       = aws_kms_key.kms_key_3.arn
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enabled_cloudwatch_logs_exports       = var.rds_enabled_cloudwatch_logs_exports

  maintenance_window       = var.rds_maintenance_window
  backup_window            = var.rds_backup_window
  backup_retention_period  = var.rds_backup_retention_period
  delete_automated_backups = var.rds_delete_automated_backups
  skip_final_snapshot      = var.rds_skip_final_snapshot

  network_type         = var.rds_network_type
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group_1.name

  copy_tags_to_snapshot  = var.rds_copy_tags_to_snapshot
  deletion_protection    = var.rds_deletion_protection
  vpc_security_group_ids = [aws_security_group.rds_security_group_1.id]

  tags = {
    Name = "db-gitlab-1"
  }

  depends_on = [aws_db_subnet_group.rds_subnet_group_1]
}

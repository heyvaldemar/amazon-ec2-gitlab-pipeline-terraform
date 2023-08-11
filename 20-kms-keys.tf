# KMS key creation
resource "aws_kms_key" "kms_key_1" {
  description             = "KMS key for terraform state storage bucket"
  deletion_window_in_days = var.kms_key_1_default_retention_days
  enable_key_rotation     = true
}

# AWS KMS alias creation
resource "aws_kms_alias" "kms_key_1_alias" {
  name          = "alias/terraform-bucket-key-gitlab-1"
  target_key_id = aws_kms_key.kms_key_1.key_id

  depends_on = [aws_kms_key.kms_key_1]
}

# KMS key creation
resource "aws_kms_key" "kms_key_2" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = var.kms_key_2_default_retention_days
  enable_key_rotation     = true
}

# AWS KMS alias creation
resource "aws_kms_alias" "kms_key_2_alias" {
  name          = "alias/dynamodb-table-encryption-gitlab-1"
  target_key_id = aws_kms_key.kms_key_2.key_id

  depends_on = [aws_kms_key.kms_key_2]
}

# KMS key creation
resource "aws_kms_key" "kms_key_3" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = var.kms_key_3_default_retention_days
  enable_key_rotation     = true
}

# AWS KMS alias creation
resource "aws_kms_alias" "kms_key_3_alias" {
  name          = "alias/performance-insights-rds-1"
  target_key_id = aws_kms_key.kms_key_3.key_id

  depends_on = [aws_kms_key.kms_key_3]
}

# KMS key creation
resource "aws_kms_key" "kms_key_4" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = var.kms_key_4_default_retention_days
  enable_key_rotation     = true
}

# AWS KMS alias creation
resource "aws_kms_alias" "kms_key_4_alias" {
  name          = "alias/ebs-1-volume-encryption-gitlab-1"
  target_key_id = aws_kms_key.kms_key_4.key_id

  depends_on = [aws_kms_key.kms_key_4]
}

# KMS key creation
resource "aws_kms_key" "kms_key_5" {
  description             = "KMS key for backup EBS volume encryption"
  deletion_window_in_days = var.kms_key_5_default_retention_days
  enable_key_rotation     = true
}

# AWS KMS alias creation
resource "aws_kms_alias" "kms_key_5_alias" {
  name          = "alias/backup-ebs-volume-1-encryption-gitlab-1"
  target_key_id = aws_kms_key.kms_key_5.key_id

  depends_on = [aws_kms_key.kms_key_5]
}

# Database Secrets
data "aws_secretsmanager_secret_version" "db_secret_1" {
  secret_id = var.db_secret_1_arn
}

locals {
  rds_db_credentials_1 = jsondecode(data.aws_secretsmanager_secret_version.db_secret_1.secret_string)
}

# Microsoft Azure OAuth2 Secrets
data "aws_secretsmanager_secret_version" "azure_oauth2_secret_1" {
  secret_id = var.azure_oauth2_secret_1_arn
}

locals {
  azure_oauth2_credentials_1 = jsondecode(data.aws_secretsmanager_secret_version.azure_oauth2_secret_1.secret_string)
}

# SMTP Secrets
data "aws_secretsmanager_secret_version" "smtp_secret_1" {
  secret_id = var.smtp_secret_1_arn
}

locals {
  smtp_credentials_1 = jsondecode(data.aws_secretsmanager_secret_version.smtp_secret_1.secret_string)
}

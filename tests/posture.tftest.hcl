# What this configuration promises with its default variables, asserted on
# a plan against mocked providers: no AWS account, no credentials, nothing
# created. Generated from the configuration's own attributes and kept in
# the repository; tests/plant-violations.sh breaks each promise on a copy
# and requires this file to notice.

mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      secret_string = "{\"client_id\": \"e2e-test-client_id\", \"client_secret\": \"e2e-test-client_secret\", \"ps_gitlab_password\": \"e2e-test-ps_gitlab_password\", \"ps_gitlab_username\": \"e2e-test-ps_gitlab_username\", \"smtp_password\": \"e2e-test-smtp_password\", \"smtp_username\": \"e2e-test-smtp_username\", \"tenant_id\": \"e2e-test-tenant_id\"}"
    }
  }
  mock_data "aws_eks_cluster" {
    defaults = {
      endpoint              = "https://eks.example.test"
      certificate_authority = [{ data = "dGVzdA==" }]
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "local" {}

mock_provider "random" {}

mock_provider "tls" {}

run "the_defaults_are_the_secure_ones" {
  command = plan

  assert {
    condition     = aws_db_instance.db_instance_1.storage_encrypted == true
    error_message = "db_instance_1 stores data unencrypted"
  }

  assert {
    condition     = aws_db_instance.db_instance_1.publicly_accessible == false
    error_message = "db_instance_1 is reachable from the internet"
  }

  assert {
    condition     = aws_db_instance.db_instance_1.deletion_protection == true
    error_message = "db_instance_1 can be deleted by one apply"
  }

  assert {
    condition     = aws_db_instance.db_instance_1.iam_database_authentication_enabled == true
    error_message = "db_instance_1 does not accept IAM authentication"
  }

  assert {
    condition     = aws_db_instance.db_instance_1.backup_retention_period >= 7
    error_message = "db_instance_1 keeps less than a week of automated backups"
  }

  assert {
    condition     = alltrue([for s in aws_dynamodb_table.dynamodb_terraform_state_lock_1.server_side_encryption : s.enabled == true])
    error_message = "dynamodb_terraform_state_lock_1 is not encrypted with its own key"
  }

  assert {
    condition     = alltrue([for p in aws_dynamodb_table.dynamodb_terraform_state_lock_1.point_in_time_recovery : p.enabled == true])
    error_message = "dynamodb_terraform_state_lock_1 cannot be restored to a point in time"
  }

  assert {
    condition     = aws_ebs_volume.backup_ebs_volume_1.encrypted == true
    error_message = "backup_ebs_volume_1 is not encrypted"
  }

  assert {
    condition     = aws_ebs_volume.ebs_volume_1.encrypted == true
    error_message = "ebs_volume_1 is not encrypted"
  }

  assert {
    condition     = aws_flow_log.vpc_1_flow_logs.traffic_type == "ALL"
    error_message = "vpc_1_flow_logs does not record rejected and accepted traffic both"
  }

  assert {
    condition     = alltrue([for m in aws_instance.instance_1.metadata_options : m.http_tokens == "required"])
    error_message = "instance_1 answers IMDSv1"
  }

  assert {
    condition     = alltrue([for r in aws_instance.instance_1.root_block_device : r.encrypted == true])
    error_message = "instance_1 has an unencrypted root volume"
  }

  assert {
    condition     = aws_kms_key.kms_key_1.enable_key_rotation == true
    error_message = "kms_key_1 does not rotate its key material"
  }

  assert {
    condition     = aws_kms_key.kms_key_2.enable_key_rotation == true
    error_message = "kms_key_2 does not rotate its key material"
  }

  assert {
    condition     = aws_kms_key.kms_key_3.enable_key_rotation == true
    error_message = "kms_key_3 does not rotate its key material"
  }

  assert {
    condition     = aws_kms_key.kms_key_4.enable_key_rotation == true
    error_message = "kms_key_4 does not rotate its key material"
  }

  assert {
    condition     = aws_kms_key.kms_key_5.enable_key_rotation == true
    error_message = "kms_key_5 does not rotate its key material"
  }

  assert {
    condition     = aws_lb.alb_1.drop_invalid_header_fields == true
    error_message = "alb_1 forwards malformed headers"
  }

  assert {
    condition     = alltrue([for a in aws_lb_listener.alb_1_http_listener_1.default_action : a.type == "redirect"])
    error_message = "alb_1_http_listener_1 serves plain HTTP instead of redirecting"
  }

  assert {
    condition     = strcontains(aws_lb_listener.alb_1_https_listener_1.ssl_policy, "TLS13")
    error_message = "alb_1_https_listener_1 accepts a policy without TLS 1.3"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.block_public_acls == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.block_public_policy == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.ignore_public_acls == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.restrict_public_buckets == true
    error_message = "bucket_1_public_access_block_block leaves a way to make the bucket public"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.block_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.block_public_policy == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.ignore_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.restrict_public_buckets == true
    error_message = "log_bucket_1_public_access_block_block leaves a way to make the bucket public"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.log_bucket_2_public_access_block_block.block_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_2_public_access_block_block.block_public_policy == true && aws_s3_bucket_public_access_block.log_bucket_2_public_access_block_block.ignore_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_2_public_access_block_block.restrict_public_buckets == true
    error_message = "log_bucket_2_public_access_block_block leaves a way to make the bucket public"
  }

  assert {
    condition     = alltrue([for r in aws_s3_bucket_server_side_encryption_configuration.bucket_1_sse_configuration.rule : alltrue([for x in r.apply_server_side_encryption_by_default : x.sse_algorithm == "aws:kms"])])
    error_message = "bucket_1_sse_configuration does not encrypt with a KMS key"
  }

  assert {
    condition     = alltrue([for r in aws_s3_bucket_server_side_encryption_configuration.log_bucket_1_sse_configuration.rule : alltrue([for x in r.apply_server_side_encryption_by_default : x.sse_algorithm == "aws:kms"])])
    error_message = "log_bucket_1_sse_configuration does not encrypt with a KMS key"
  }

  assert {
    condition     = alltrue([for r in aws_s3_bucket_server_side_encryption_configuration.log_bucket_2_sse_configuration.rule : alltrue([for x in r.apply_server_side_encryption_by_default : x.sse_algorithm == "aws:kms"])])
    error_message = "log_bucket_2_sse_configuration does not encrypt with a KMS key"
  }

  assert {
    condition     = alltrue([for v in aws_s3_bucket_versioning.bucket_1_versioning.versioning_configuration : v.status == "Enabled"])
    error_message = "bucket_1_versioning does not keep old versions"
  }

  assert {
    condition     = alltrue([for v in aws_s3_bucket_versioning.log_bucket_1_versioning.versioning_configuration : v.status == "Enabled"])
    error_message = "log_bucket_1_versioning does not keep old versions"
  }

  assert {
    condition     = alltrue([for v in aws_s3_bucket_versioning.log_bucket_2_versioning.versioning_configuration : v.status == "Enabled"])
    error_message = "log_bucket_2_versioning does not keep old versions"
  }

  assert {
    condition     = alltrue([for i in aws_security_group.alb_1_security_group_1.ingress : i.cidr_blocks == null || !contains(i.cidr_blocks, "0.0.0.0/0") || contains([80, 443], i.from_port)])
    error_message = "alb_1_security_group_1 opens a port other than 80 and 443 to the internet"
  }

  assert {
    condition     = alltrue([for i in aws_security_group.rds_security_group_1.ingress : i.cidr_blocks == null || !contains(i.cidr_blocks, "0.0.0.0/0") || contains([80, 443], i.from_port)])
    error_message = "rds_security_group_1 opens a port other than 80 and 443 to the internet"
  }

  assert {
    condition     = alltrue([for i in aws_security_group.redis_security_group_1.ingress : i.cidr_blocks == null || !contains(i.cidr_blocks, "0.0.0.0/0") || contains([80, 443], i.from_port)])
    error_message = "redis_security_group_1 opens a port other than 80 and 443 to the internet"
  }
}

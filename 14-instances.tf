# Generate the GitLab configuration using the template and variable values
locals {
  gitlab_config = templatefile("${path.root}/templates/gitlab.rb.tpl", {
    repositories_storage_path  = var.ebs_volume_1_mount_point
    gitlab_ssh_clone_endpoint  = var.gitlab_ssh_endpoint
    db_host                    = aws_db_instance.db_instance_1.endpoint
    db_name                    = var.rds_db_1_name
    redis_host                 = aws_elasticache_cluster.redis_1.cache_nodes[0].address
    db_username                = local.rds_db_credentials_1["ps_gitlab_username"]
    db_password                = local.rds_db_credentials_1["ps_gitlab_password"]
    lfs_storage_path           = "${var.ebs_volume_1_mount_point}/lfs-objects"
    azure_oauth2_client_id     = local.azure_oauth2_credentials_1["client_id"]
    azure_oauth2_client_secret = local.azure_oauth2_credentials_1["client_secret"]
    azure_oauth2_tenant_id     = local.azure_oauth2_credentials_1["tenant_id"]
    smtp_username              = local.smtp_credentials_1["smtp_username"]
    smtp_password              = local.smtp_credentials_1["smtp_password"]
    gitlab_email_from          = var.gitlab_reply_from
    gitlab_email_reply_to      = var.gitlab_reply_to
    gitlab_backup_s3_region    = var.region
  })
}

# EC2 Instance creation
resource "aws_instance" "instance_1" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  availability_zone      = var.ec2_availability_zone
  subnet_id              = aws_subnet.private_subnet_1a.id
  instance_type          = var.ec2_instance_1_type
  key_name               = aws_key_pair.key_pair_1.key_name
  monitoring             = var.ec2_monitoring
  vpc_security_group_ids = [aws_security_group.ec2_security_group_1.id]

  # Enforcing IMDSv2
  metadata_options {
    http_tokens                 = var.ec2_http_tokens
    http_put_response_hop_limit = var.ec2_http_put_response_hop_limit
    http_endpoint               = var.ec2_http_endpoint
  }

  # Root volume size configuration
  root_block_device {
    volume_size           = var.ec2_root_volume_1_size_gb
    volume_type           = var.ec2_root_volume_1_type
    encrypted             = var.ec2_root_volume_1_encryption
    delete_on_termination = var.ec2_delete_on_termination
  }

  # Generate the user data script using the template and variable values
  user_data = templatefile("${path.root}/templates/user_data.sh.tpl", {
    timestamp                              = timestamp()
    gitlab_config_file                     = local.gitlab_config
    ebs_volume_1_name                      = var.ebs_volume_1_name
    ebs_volume_1_mount_point               = var.ebs_volume_1_mount_point
    backup_ebs_volume_1_name               = var.backup_ebs_volume_1_name
    backup_ebs_volume_1_mount_point        = var.backup_ebs_volume_1_mount_point
    gitlab_backup_ebs_volume_1_mount_point = var.gitlab_backup_ebs_volume_1_mount_point
    gitlab_external_url_install            = var.gitlab_external_url
    db_host_install                        = aws_db_instance.db_instance_1.endpoint
    db_password_install                    = local.rds_db_credentials_1["ps_gitlab_password"]
    gitlab_mail_domain_install             = var.gitlab_mail_domain
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "gitlab-1"
  }

  depends_on = [
    aws_security_group.ec2_security_group_1,
    tls_private_key.private_key_1,
    aws_key_pair.key_pair_1,
    aws_db_instance.db_instance_1
  ]
}

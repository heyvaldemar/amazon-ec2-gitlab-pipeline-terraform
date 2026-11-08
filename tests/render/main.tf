# The instance's user_data, rendered from the template with stand-in values,
# so tests/posture.tftest.hcl can read the script the instance would run.
# The configuration renders it with timestamp(), which makes it unknown until
# apply; this renders the same template with every value known at plan.

variable "password" {
  description = "A stand-in database password the assertions look for"
  type        = string
}

output "user_data" {
  value = templatefile("${path.module}/../../templates/user_data.sh.tpl", {
    timestamp                              = "2026-01-01T00:00:00Z"
    gitlab_config_file                     = "external_url 'https://gitlab.example.test'"
    ebs_volume_1_name                      = "/dev/xvdf"
    ebs_volume_1_mount_point               = "/mnt/gitlab"
    backup_ebs_volume_1_name               = "/dev/xvdg"
    backup_ebs_volume_1_mount_point        = "/mnt/backups"
    gitlab_backup_ebs_volume_1_mount_point = "/mnt/backups/gitlab"
    gitlab_external_url_install            = "https://gitlab.example.test"
    db_host_install                        = "db.example.test:5432"
    db_password_install                    = var.password
    gitlab_mail_domain_install             = "example.test"
  })
}

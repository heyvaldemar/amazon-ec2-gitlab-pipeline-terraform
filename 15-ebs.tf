# EBS volume creation
resource "aws_ebs_volume" "ebs_volume_1" {
  availability_zone = var.ec2_availability_zone
  size              = var.ebs_volume_1_size_gb
  type              = var.ebs_volume_1_type
  encrypted         = var.ebs_volume_1_encryption
  kms_key_id        = aws_kms_key.kms_key_4.arn

  tags = {
    Name = "ebs-volume-gitlab-1"
  }
}

# EBS volume attachment
resource "aws_volume_attachment" "ebs_volume_1_attachment" {
  device_name = var.ebs_volume_1_name
  volume_id   = aws_ebs_volume.ebs_volume_1.id
  instance_id = aws_instance.instance_1.id

  depends_on = [
    aws_ebs_volume.ebs_volume_1,
    aws_instance.instance_1
  ]
}

# EBS volume creation
resource "aws_ebs_volume" "backup_ebs_volume_1" {
  availability_zone = var.ec2_availability_zone
  size              = var.backup_ebs_volume_1_size_gb
  type              = var.backup_ebs_volume_1_type
  encrypted         = var.backup_ebs_volume_1_encryption
  kms_key_id        = aws_kms_key.kms_key_5.arn

  tags = {
    Name = "backup-ebs-volume-gitlab-1"
  }
}

# EBS volume attachment
resource "aws_volume_attachment" "backup_ebs_volume_1_attachment" {
  device_name = var.backup_ebs_volume_1_name
  volume_id   = aws_ebs_volume.backup_ebs_volume_1.id
  instance_id = aws_instance.instance_1.id

  depends_on = [
    aws_ebs_volume.backup_ebs_volume_1,
    aws_instance.instance_1
  ]
}

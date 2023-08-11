# Private key encryption configuration
resource "tls_private_key" "private_key_1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Private key creation
resource "aws_key_pair" "key_pair_1" {
  key_name   = var.key_pair_1_name
  public_key = tls_private_key.private_key_1.public_key_openssh

  # Private key export for Linux and macOS
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.private_key_1.private_key_pem}' > ./'${var.key_pair_1_name}'.pem
      chmod 600 ./'${var.key_pair_1_name}'.pem
    EOT
  }

  depends_on = [tls_private_key.private_key_1]
}

# Private key export for Windows
# resource "local_file" "key_pair_1_export" {
#   filename = "${var.key_pair_1_name}.pem"
#   file_permission = "600"
#   content = tls_private_key.private_key_1.private_key_pem

#   depends_on = [tls_private_key.private_key_1]
# }

# =============================================================================
# Key Pair Module - SSH Key Generation
# Finish Line 2026 Infrastructure
# Assignment: §71, §73 - Terraform-managed SSH keypairs
# =============================================================================

# Generate RSA 4096-bit key pair
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key to AWS EC2
resource "aws_key_pair" "finishline_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh

  tags = merge(local.common_tags, {
    Name = var.key_name
    Type = "KeyPair"
  })
}

# Download private key to local filesystem
resource "local_file" "private_key" {
  filename        = "${path.module}/${var.key_name}.pem"
  content         = tls_private_key.rsa_4096.private_key_pem
  file_permission = "0600"

  provisioner "local-exec" {
    command = "chmod 400 ${self.filename}"
  }
}

# Output warning about key location
resource "null_resource" "key_warning" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo ""
      echo "╔═══════════════════════════════════════════════════════════╗"
      echo "║  ⚠️  SSH PRIVATE KEY GENERATED ⚠️                         ║"
      echo "╚═══════════════════════════════════════════════════════════╝"
      echo ""
      echo "Location: ${local_file.private_key.filename}"
      echo "Permissions: 0600"
      echo ""
      echo "IMPORTANT:"
      echo "1. Move this file to a secure location:"
      echo "   mv ${local_file.private_key.filename} ~/.ssh/"
      echo ""
      echo "2. Set correct permissions:"
      echo "   chmod 400 ~/.ssh/${var.key_name}.pem"
      echo ""
      echo "3. Delete from terraform directory after copying!"
      echo ""
    EOT
  }
}

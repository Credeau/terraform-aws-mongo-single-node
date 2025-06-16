# ------------------------------------------------
# 📡 Network & Connectivity
# ------------------------------------------------

# The resolved IP address of the MongoDB instance (public or private based on setup)
output "host_address" {
  value = aws_network_interface.mongo_eni.private_ip
}

# The port MongoDB is listening on (default: 27017)
output "port" {
  value = var.mongo_port
}

# ------------------------------------------------
# 📛 Identifiers & Metadata
# ------------------------------------------------

# Common application-specific identifier used for tagging and metric grouping
output "application_identifier" {
  value = local.stack_identifier
}

# Availability zone in which the MongoDB resources are deployed
output "availability_zone" {
  value = data.aws_subnet.main.availability_zone
}

# AMI ID of the Ubuntu image used for MongoDB instance
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

# Bucket on which the MongoDB bootstrap assets are uploaded
output "assets_bucket" {
  value = aws_s3_bucket.mongo_assets.bucket
}

# ------------------------------------------------
# 🔐 Security & Access
# ------------------------------------------------

# IAM role ARN attached to the MongoDB instances
output "iam_role_arn" {
  value = aws_iam_role.main.arn
}

# Security group ID attached to the MongoDB instance
output "security_group_id" {
  value = aws_security_group.mongodb_sg.id
}

# ------------------------------------------------
# 🧱 Storage & Instance Details
# ------------------------------------------------

# Device path where the MongoDB volume is attached on the instance
output "volume_mount_path" {
  value = format("Initially attached on: %s. The actual mounting happens in userdata.", aws_volume_attachment.mongo_attach.device_name)
}

# EC2 instance ID for the MongoDB host
output "instance_id" {
  value = aws_instance.mongo.id
}

# Backup enabled flag
output "backup_enabled" {
  value = var.enable_backup
}

# Mongo storage disk backup vault name
output "backup_vault_name" {
  value = var.enable_backup ? aws_backup_vault.mongo_ebs_backup[0].name : null
}

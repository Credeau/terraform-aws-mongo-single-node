resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "aws_s3_bucket" "mongo_assets" {
  bucket        = format("%s-assets-%s", local.stack_identifier, random_string.suffix.result)
  force_destroy = true

  tags = merge(local.common_tags, {
    Name         = format("%s-assets", local.stack_identifier),
    ResourceType = "storage"
  })
}

resource "aws_s3_bucket_public_access_block" "mongo_assets" {
  bucket = aws_s3_bucket.mongo_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "mongo_cloudwatch_script" {
  bucket       = aws_s3_bucket.mongo_assets.id
  key          = "scripts/mongo_cloudwatch.py"
  source       = "${path.module}/python/metrics.py"
  content_type = "text/x-python"
}

resource "aws_s3_object" "mongod_config" {
  bucket = aws_s3_bucket.mongo_assets.id
  key    = "config/mongod.conf"

  content = templatefile("${path.module}/configs/mongod.conf", {
    compression_type    = aws_ssm_parameter.compression_type.value
    port                = aws_ssm_parameter.port.value
    mongo_data_location = aws_ssm_parameter.data_path.value
  })

  content_type = "text/plain"
}

resource "aws_s3_object" "mongod_service_override_config" {
  bucket       = aws_s3_bucket.mongo_assets.id
  key          = "config/mongod.service.override"
  source       = "${path.module}/configs/mongod.service.override"
  content_type = "text/plain"
}

resource "aws_s3_object" "cloudwatch_agent_config" {
  bucket = aws_s3_bucket.mongo_assets.id
  key    = "config/cwa_config.json"

  content = templatefile("${path.module}/configs/cwa_config.json", {
    application_identifier = local.stack_identifier
    volume_mount_path      = aws_ssm_parameter.data_path.value
  })

  content_type = "text/plain"
}

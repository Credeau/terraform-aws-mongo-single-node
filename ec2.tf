resource "aws_instance" "mongo" {
  ami                  = local.ubuntu_ami_id
  instance_type        = var.instance_type
  key_name             = var.key_pair_name
  iam_instance_profile = aws_iam_instance_profile.mongo.name

  disable_api_stop        = true
  disable_api_termination = true

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mongo_eni.id
  }

  depends_on = [
    aws_s3_bucket.mongo_assets,
    aws_s3_object.cloudwatch_agent_config,
    aws_s3_object.mongo_cloudwatch_script,
    aws_s3_object.mongod_config,
    aws_s3_object.mongod_service_override_config
  ]

  user_data = templatefile("${path.module}/files/userdata.sh.tftpl", {
    mongo_user_name                = var.mongo_user_name
    mongo_password                 = var.mongo_password
    mongo_port                     = var.mongo_port
    application_identifier         = local.stack_identifier
    mongo_data_location            = local.mongo_data_path
    cloudwatch_script_s3_uri       = format("s3://%s/%s", aws_s3_bucket.mongo_assets.bucket, aws_s3_object.mongo_cloudwatch_script.key)
    mongo_config_s3_uri            = format("s3://%s/%s", aws_s3_bucket.mongo_assets.bucket, aws_s3_object.mongod_config.key)
    mongod_service_override_s3_uri = format("s3://%s/%s", aws_s3_bucket.mongo_assets.bucket, aws_s3_object.mongod_service_override_config.key)
    cloudwatch_config_s3_uri       = format("s3://%s/%s", aws_s3_bucket.mongo_assets.bucket, aws_s3_object.cloudwatch_agent_config.key)
  })

  user_data_replace_on_change = true

  tags = merge(local.common_tags, {
    Name         = local.stack_identifier,
    ResourceType = "database"
  })
}

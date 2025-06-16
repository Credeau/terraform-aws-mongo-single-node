data "aws_ssm_parameter" "mongo_user_name" {
  name = "DUMMY_MONGO_USER"
  with_decryption = true
}
data "aws_ssm_parameter" "mongo_password" {
  name = "DUMMY_MONGO_PASSWORD"
  with_decryption = true
}

module "mongodb" {
  source = "git::https://github.com/credeau/terraform-aws-mongo-single-node.git?ref=v1.0.1"

  application                            = "mobile-forge"
  environment                            = "prod"
  region                                 = "ap-south-1"
  stack_owner                            = "tech@credeau.com"
  stack_team                             = "devops"
  organization                           = "credeau"
  alert_email_recipients                 = []
  vpc_id                                 = "vpc-00000000000000000"
  subnet_id                              = "subnet-00000000000000000"
  mongodb_whitelisted_cidrs              = ["52.52.0.0/16"]
  mongodb_whitelisted_sg_ids             = ["sg-00000000000000000"]
  ssh_whitelisted_cidrs                  = []
  ssh_whitelisted_sg_ids                 = []
  instance_type                          = "t3a.medium"
  key_pair_name                          = "mobile-forge-demo"
  cpu_threshold                          = 65
  memory_threshold                       = 75
  disk_threshold                         = 70
  mongo_user_name                        = data.aws_ssm_parameter.mongo_user_name.value
  mongo_password                         = data.aws_ssm_parameter.mongo_password.value
  mongo_default_storage_compression_type = "zstd"
  mongo_port                             = 27017
  disk_size                              = 100
  disk_iops                              = 3000
  encrypt_storage                        = true
  base_snapshot_id                       = null
  mongo_data_location                    = "/var/lib/mongodb"
  enable_backup                          = true
  backup_schedule                        = "cron(0 0 ? * * *)"
  backup_retention_days                  = 7
}

output "mongodb" {
  value = module.mongodb
}
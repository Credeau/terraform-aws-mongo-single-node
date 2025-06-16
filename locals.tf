locals {
  common_tags = {
    Stage    = var.environment
    Owner    = var.stack_owner
    Team     = var.stack_team
    Pipeline = var.application
    Org      = var.organization
  }

  stack_identifier       = format("%s-mongo-%s", var.application, var.environment)

  ssm_config_path_prefix       = format("/%s/%s/mongo", var.organization, local.stack_identifier)
  ssm_ami_parameter_name       = format("%s/ubuntu-ami-id", local.ssm_config_path_prefix)
  ssm_data_path_parameter_name = format("%s/data-path", local.ssm_config_path_prefix)
}
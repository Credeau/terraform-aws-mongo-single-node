locals {
  common_tags = {
    Stage    = var.environment
    Owner    = var.stack_owner
    Team     = var.stack_team
    Pipeline = var.application
    Org      = var.organization
  }

  stack_identifier       = format("%s-mongo-%s", var.application, var.environment)
  ssm_ami_parameter_name = format("/%s/%s/mongo/ubuntu-ami-id", var.organization, local.stack_identifier)
  ubuntu_ami_id          = data.aws_ssm_parameter.ubuntu_ami.id == null ? data.aws_ami.ubuntu[0].id : data.aws_ssm_parameter.ubuntu_ami.value
}
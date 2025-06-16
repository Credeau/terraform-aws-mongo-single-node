# Fetch properties of passed Subnet ID
data "aws_subnet" "main" {
  id = var.subnet_id
}

# Fetch AMI Id for mongo instance
# 1. Try to read existing AMI ID from SSM Parameter Store first
data "aws_ssm_parameter" "ubuntu_ami" {
  name = local.ssm_ami_parameter_name
}

# 2. Fetch latest Ubuntu 22.04 AMI if the ssm parameter is not found
data "aws_ami" "ubuntu" {
  count = data.aws_ssm_parameter.ubuntu_ami.id == null ? 1 : 0

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Store the AMI ID in SSM Parameter Store
resource "aws_ssm_parameter" "ubuntu_ami" {
  name        = local.ssm_ami_parameter_name
  description = "Ubuntu AMI ID for MongoDB instance (Caution! do not alter this manually)"
  type        = "String"
  value       = data.aws_ami.ubuntu.id
  overwrite   = false  # This ensures we don't overwrite the value once set
}

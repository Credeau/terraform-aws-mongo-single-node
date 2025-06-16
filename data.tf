# Fetch properties of passed Subnet ID
data "aws_subnet" "main" {
  id = var.subnet_id
}

# Fetch AMI Id for mongo instance
data "aws_ami" "ubuntu" {
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

# Prevents changing the data path after the first run
resource "aws_ssm_parameter" "data_path" {
  name        = local.ssm_data_path_parameter_name
  description = "MongoDB data storage path (Caution! do not alter this manually)"
  type        = "String"
  value       = var.mongo_data_location
  overwrite   = false  # This ensures we don't overwrite the value once set
}

resource "aws_security_group" "mongodb_sg" {
  name        = format("%s-sg", local.stack_identifier)
  description = "Security group for MongoDB instance"
  vpc_id      = var.vpc_id

  # MongoDB port
  ingress {
    description     = "MongoDB Access"
    from_port       = var.mongo_port
    to_port         = var.mongo_port
    protocol        = "tcp"
    cidr_blocks     = var.mongodb_whitelisted_cidrs
    security_groups = var.mongodb_whitelisted_sg_ids
  }

  # SSH access
  ingress {
    description     = "SSH Access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = var.ssh_whitelisted_cidrs
    security_groups = var.ssh_whitelisted_sg_ids
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # This is needed as the instance downloads artifacts from sources like MongoDB and others
  }

  tags = {
    Name         = format("%s-sg", local.stack_identifier),
    ResourceType = "security"
  }
}

resource "aws_network_interface" "mongo_eni" {
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.mongodb_sg.id]

  tags = merge(local.common_tags, {
    Name         = format("%s-eni", local.stack_identifier),
    ResourceType = "network"
  })
}

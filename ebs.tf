resource "aws_ebs_volume" "mongo_data" {
  availability_zone    = data.aws_subnet.main.availability_zone
  size                 = var.disk_size
  type                 = "gp3"
  iops                 = var.disk_iops
  multi_attach_enabled = false
  encrypted            = var.encrypt_storage
  final_snapshot       = true # A snapshot will be created before volume deletion, this safeguards potential data loss due to accidental `terraform destroy`
  snapshot_id          = var.base_snapshot_id

  tags = merge(local.common_tags, {
    Name         = format("%s-disk", local.stack_identifier),
    ResourceType = "storage"
  })
}

resource "aws_volume_attachment" "mongo_attach" {
  device_name = "/dev/sdf" # Actual mounting is going on in user data script
  volume_id   = aws_ebs_volume.mongo_data.id
  instance_id = aws_instance.mongo.id

  force_detach                   = true  # If the volume needs to be detached, it will be forcefully detached. dangerous but mitigated by `stop_instance_before_detaching` below
  stop_instance_before_detaching = true  # Ensures that the instance is stopped before any volume detachment occurs, which helps prevent data corruption
  skip_destroy                   = false # The volume attachment will be destroyed when you run terraform destroy
}
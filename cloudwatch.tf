resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name          = format("%s-cpu-warning", local.stack_identifier)
  alarm_description   = "This metric alarm keeps a watch on CPU usage and send Email Notification"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold

  dimensions = {
    InstanceId = aws_instance.mongo.id
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory_usage" {
  alarm_name          = format("%s-memory-warning", local.stack_identifier)
  alarm_description   = "This metric alarm keeps a watch on Memory usage and send Email Notification"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "MongoDBMemUsedPercent"
  namespace           = "MongoDBMetrics"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_threshold

  dimensions = {
    InstanceId = aws_instance.mongo.id
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_nvme1n1" {
  alarm_name          = format("%s-nvme1n1-disk-warning", local.stack_identifier)
  alarm_description   = "This metric alarm keeps a watch on Disk usage and send Email Notification"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "MongoDBDiskUsedPercent"
  namespace           = "MongoDBMetrics"
  period              = 60
  statistic           = "Average"
  threshold           = var.disk_threshold

  dimensions = {
    InstanceId = aws_instance.mongo.id
    path       = aws_ssm_parameter.data_path.value
    device     = "nvme1n1"
    fstype     = "ext4"
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "disk_usage_xvdf" {
  alarm_name          = format("%s-xvdf-disk-warning", local.stack_identifier)
  alarm_description   = "This metric alarm keeps a watch on Disk usage and send Email Notification"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "MongoDBDiskUsedPercent"
  namespace           = "MongoDBMetrics"
  period              = 60
  statistic           = "Average"
  threshold           = var.disk_threshold

  dimensions = {
    InstanceId = aws_instance.mongo.id
    path       = aws_ssm_parameter.data_path.value
    device     = "xvdf"
    fstype     = "ext4"
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}
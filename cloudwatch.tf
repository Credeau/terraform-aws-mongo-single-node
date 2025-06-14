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
    InstanceId = aws_instance.kafka.id
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
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_threshold

  dimensions = {
    InstanceId = aws_instance.kafka.id
  }

  alarm_actions = [
    aws_autoscaling_policy.upscale.arn,
    aws_sns_topic.alert_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "disk_usage" {
  alarm_name          = format("%s-disk-warning", local.stack_identifier)
  alarm_description   = "This metric alarm keeps a watch on Disk usage and send Email Notification"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = var.disk_threshold

  dimensions = {
    InstanceId = aws_instance.kafka.id
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}
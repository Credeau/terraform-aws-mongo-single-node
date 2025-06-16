resource "aws_iam_instance_profile" "mongo" {
  name = format("%s-profile", local.stack_identifier)
  role = aws_iam_role.main.name

  tags = local.common_tags
}

resource "aws_iam_role" "main" {
  name = format("%s-role", local.stack_identifier)

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "ssh_policy" {
  role       = aws_iam_role.main.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "main" {
  name = format("%s-%s-policy", var.application, var.environment)
  role = aws_iam_role.main.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3Access",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "backup_role" {
  name = format("%s-backup-role", local.stack_identifier)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}
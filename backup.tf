resource "aws_backup_vault" "mongo_ebs_backup" {
  count = var.enable_backup ? 1 : 0

  name = format("%s-backup-vault", local.stack_identifier)
  tags = merge(local.common_tags, {
    Name         = format("%s-backup-vault", local.stack_identifier),
    ResourceType = "backup"
  })
}

resource "aws_backup_plan" "mongo_ebs_backup" {
  count = var.enable_backup ? 1 : 0

  name = format("%s-backup-plan", local.stack_identifier)

  rule {
    rule_name         = "backup_schedule"
    target_vault_name = aws_backup_vault.mongo_ebs_backup[0].name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = local.common_tags
}

resource "aws_backup_selection" "mongo_backup_selection" {
  count = var.enable_backup ? 1 : 0

  name         = format("%s-backup-selection", local.stack_identifier)
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.mongo_ebs_backup[0].id

  resources = [
    aws_ebs_volume.mongo_data.arn
  ]
}
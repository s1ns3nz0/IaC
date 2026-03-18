# Builder step 3: enable_backup
# Completely optional — only included when enable_backup = true

variable "instance_arn"   {}
variable "enable_backup"  { default = false }

resource "aws_backup_selection" "this" {
  count        = var.enable_backup ? 1 : 0   # ← optional step

  name         = "backup-${var.instance_arn}"
  plan_id      = aws_backup_plan.this[0].id
  iam_role_arn = "arn:aws:iam::123456789012:role/backup-role"

  resources = [var.instance_arn]
}

resource "aws_backup_plan" "this" {
  count = var.enable_backup ? 1 : 0

  name = "plan-${var.instance_arn}"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = "Default"
    schedule          = "cron(0 12 * * ? *)"
  }
}

output "backup_plan_id" {
  value = var.enable_backup ? aws_backup_plan.this[0].id : null
}
# This IS the Builder.
# It assembles all steps together in the correct order,
# passing outputs from one step as inputs to the next.

variable "name"               {}
variable "instance_type"      { default = "t3.medium" }
variable "storage_gb"         { default = 20 }
variable "tags"               { default = {} }
variable "enable_monitoring"  { default = false }
variable "enable_backup"      { default = false }

# ── Step 1: compute (always runs) ────────────────────────────
module "compute" {
  source        = "./steps/compute"
  name          = var.name
  instance_type = var.instance_type    # set_instance_type()
  storage_gb    = var.storage_gb       # set_storage()
  tags          = var.tags
}

# ── Step 2: monitoring (optional) ────────────────────────────
module "monitoring" {
  source             = "./steps/monitoring"
  instance_id        = module.compute.instance_id
  enable_monitoring  = var.enable_monitoring   # enable_monitoring()
}

# ── Step 3: backup (optional) ─────────────────────────────────
module "backup" {
  source         = "./steps/backup"
  instance_arn   = module.compute.instance_arn
  enable_backup  = var.enable_backup           # enable_backup()
}

# ── Outputs: the finished product ────────────────────────────
output "instance_id"    { value = module.compute.instance_id }
output "alarm_arn"      { value = module.monitoring.alarm_arn }
output "backup_plan_id" { value = module.backup.backup_plan_id }
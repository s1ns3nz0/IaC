# Another COMPOSITE — assembles vpc + rds leaves.
# Same uniform interface as web_tier.

variable "name"       {}
variable "cidr_block" {}

# ── Calls LEAF: vpc ──────────────────────────────────────
module "vpc" {
  source     = "../vpc"
  name       = "${var.name}-vpc"
  cidr_block = var.cidr_block
}

# ── Calls LEAF: rds ──────────────────────────────────────
module "rds" {
  source    = "../rds"
  name      = "${var.name}-rds"
  subnet_id = module.vpc.subnet_id   # ← wires vpc output → rds input
}

# ✅ OUTPUTS
output "vpc_id"      { value = module.vpc.vpc_id }
output "db_endpoint" { value = module.rds.db_endpoint }
output "db_name"     { value = module.rds.db_name }
# This COMPOSITE assembles LEAF modules together.
# The caller (root) doesn't need to know about vpc or ec2 — 
# web_tier handles that internally.

variable "name"           {}
variable "cidr_block"     {}
variable "instance_count" { default = 2 }

# ── Calls LEAF: vpc ──────────────────────────────────────
module "vpc" {
  source     = "../vpc"          # ← consuming a leaf
  name       = "${var.name}-vpc"
  cidr_block = var.cidr_block
}

# ── Calls LEAF: ec2 ──────────────────────────────────────
module "ec2" {
  source    = "../ec2"           # ← consuming another leaf
  name      = "${var.name}-ec2"
  subnet_id = module.vpc.subnet_id  # ← wires vpc output → ec2 input
  count     = var.instance_count
}

# ✅ OUTPUTS — exposes a clean interface to its parent
output "vpc_id"       { value = module.vpc.vpc_id }
output "instance_ids" { value = module.ec2.instance_ids }
output "public_ips"   { value = module.ec2.public_ips }
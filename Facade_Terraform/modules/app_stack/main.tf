# This IS the Facade.
# It coordinates all four subsystems in the correct order,
# wiring outputs from one into inputs of the next.
# The client sees NONE of this complexity.

variable "name"           {}
variable "cidr_block"     { default = "10.0.0.0/16" }
variable "instance_type"  { default = "t3.medium" }
variable "instance_count" { default = 2 }

# ── Step 1: networking ───────────────────────────────────────
module "networking" {
  source     = "./subsystems/networking"
  name       = var.name
  cidr_block = var.cidr_block
}

# ── Step 2: security (needs vpc_id from networking) ──────────
module "security" {
  source = "./subsystems/security"
  name   = var.name
  vpc_id = module.networking.vpc_id    # ← wired internally
}

# ── Step 3: compute (needs subnet + security group) ──────────
module "compute" {
  source         = "./subsystems/compute"
  name           = var.name
  subnet_id      = module.networking.subnet_id   # ← wired internally
  sg_id          = module.security.app_sg_id     # ← wired internally
  instance_type  = var.instance_type
  instance_count = var.instance_count
}

# ── Step 4: database (needs subnet + security group) ─────────
module "database" {
  source    = "./subsystems/database"
  name      = var.name
  subnet_id = module.networking.subnet_id   # ← wired internally
  sg_id     = module.security.db_sg_id      # ← wired internally
}

# ── Clean outputs exposed to the client ──────────────────────
output "public_ips"  { value = module.compute.public_ips }
output "db_endpoint" { value = module.database.db_endpoint }
# environments/prod/main.tf
# This file IS the mediator — ONLY place that connects modules

# ── Module A: networking ──────────────────────────────────
module "networking" {
  source      = "../../modules/networking"
  environment = "prod"
  cidr_block  = "10.0.0.0/16"
}

# ── Module B: database ────────────────────────────────────
# Receives networking outputs — injected by mediator
module "database" {
  source      = "../../modules/database"
  environment = "prod"
  table_name  = "orders-prod"

  vpc_id     = module.networking.vpc_id              # mediator wires ✅
  subnet_ids = module.networking.private_subnet_ids  # mediator wires ✅
}

# ── Module C: lambda ──────────────────────────────────────
# Receives both networking AND database outputs — injected by mediator
module "lambda" {
  source        = "../../modules/lambda"
  environment   = "prod"
  function_name = "order-processor"

  vpc_id     = module.networking.vpc_id              # mediator wires ✅
  subnet_ids = module.networking.private_subnet_ids  # mediator wires ✅
  table_name = module.database.table_name            # mediator wires ✅
}
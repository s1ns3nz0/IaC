# The client calls ONE module with a few simple variables.
# It has zero knowledge of networking, security groups,
# subnet wiring, or RDS subnet groups.
# This is the Facade in action.

module "prod_stack" {
  source         = "./modules/app_stack"   # ← only the facade
  name           = "prod"
  cidr_block     = "10.0.0.0/16"
  instance_type  = "t3.medium"
  instance_count = 2
}

module "staging_stack" {
  source         = "./modules/app_stack"   # ← same facade, different values
  name           = "staging"
  cidr_block     = "10.1.0.0/16"
  instance_type  = "t3.small"
  instance_count = 1
}

# Client only sees the clean outputs
output "prod_ips"         { value = module.prod_stack.public_ips }
output "prod_db_endpoint" { value = module.prod_stack.db_endpoint }

# Director recipe: web server
# Calls the builder with monitoring ON, backup OFF
module "web_server" {
  source             = "./modules/server_builder"
  name               = "prod-web"
  instance_type      = "t3.medium"     # set_instance_type()
  storage_gb         = 20              # set_storage()
  enable_monitoring  = true            # enable_monitoring()
  enable_backup      = false           # ← step skipped
  tags               = { role = "web", env = "prod" }
}

# Director recipe: DB server
# Calls the builder with BOTH monitoring and backup ON
module "db_server" {
  source             = "./modules/server_builder"
  name               = "prod-db"
  instance_type      = "r5.2xlarge"   # set_instance_type()
  storage_gb         = 100            # set_storage()
  enable_monitoring  = true           # enable_monitoring()
  enable_backup      = true           # enable_backup()
  tags               = { role = "db", env = "prod" }
}

# Custom: cache server — no monitoring, no backup
module "cache_server" {
  source             = "./modules/server_builder"
  name               = "prod-cache"
  instance_type      = "m5.xlarge"
  storage_gb         = 50
  enable_monitoring  = false          # ← step skipped
  enable_backup      = false          # ← step skipped
  tags               = { role = "cache", env = "prod" }
}
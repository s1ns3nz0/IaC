# This is the CLIENT — it only calls the Factory.
# It never touches aws_instance directly.
# It never knows about instance_type, volume_size, or ports.

module "web_server" {
  source      = "./modules/server"
  name        = "prod-web"
  server_type = "web"             # Just pass the type — Factory handles the rest
}

module "db_server" {
  source      = "./modules/server"
  name        = "prod-db"
  server_type = "db"
}

module "cache_server" {
  source      = "./modules/server"
  name        = "prod-cache"
  server_type = "cache"
}

# Use the outputs — like calling .describe()
output "web_ip"   { value = module.web_server.public_ip }
output "db_type"  { value = module.db_server.instance_type }
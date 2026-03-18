# This IS the Factory.
# The caller passes in a type, and this module handles
# all the internal decision-making and resource creation.

variable "server_type" {
  description = "Type of server: web | db | cache"
  type        = string
}

variable "name" {
  description = "Name tag for the resource"
  type        = string
}

# ── The Factory logic: decides WHAT to build ─────────────────
locals {
  configs = {
    web = {
      instance_type = "t3.medium"
      volume_size   = 20
      port          = 80
    }
    db = {
      instance_type = "r5.2xlarge"
      volume_size   = 100
      port          = 5432
    }
    cache = {
      instance_type = "m5.xlarge"
      volume_size   = 50
      port          = 6379
    }
  }

  # Look up the config for the given type — like servers.get(server_type)
  config = local.configs[var.server_type]
}

# ── The Product: the actual resource being created ───────────
resource "aws_instance" "this" {
  ami           = "ami-0abcdef1234567890"
  instance_type = local.config.instance_type   # Hidden from caller!

  root_block_device {
    volume_size = local.config.volume_size      # Hidden from caller!
  }

  tags = {
    Name = var.name
    Type = var.server_type
    Port = local.config.port
  }
}

# ── Outputs: what the client can USE after creation ──────────
output "instance_id"   { value = aws_instance.this.id }
output "instance_type" { value = aws_instance.this.instance_type }
output "public_ip"     { value = aws_instance.this.public_ip }
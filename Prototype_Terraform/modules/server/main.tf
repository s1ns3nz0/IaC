# This module receives ONE clone's configuration and creates
# the real AWS resource from it.
# It doesn't know or care whether the config came from a
# prototype — it just builds what it's given.

variable "name"          {}
variable "instance_type" {}
variable "storage_gb"    {}
variable "port"          {}
variable "env"           {}
variable "role"          { default = "app" }

resource "aws_instance" "this" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.instance_type      # ← from cloned prototype

  root_block_device {
    volume_size = var.storage_gb         # ← from cloned prototype
  }

  tags = {
    Name = var.name
    Env  = var.env                       # ← potentially overridden
    Role = var.role                      # ← potentially overridden
  }
}

output "instance_id" { value = aws_instance.this.id }
output "public_ip"   { value = aws_instance.this.public_ip }
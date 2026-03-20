# Compute subsystem — EC2 instances with launch config
# Client never touches this directly

variable "name"          {}
variable "subnet_id"     {}
variable "sg_id"         {}
variable "instance_type" { default = "t3.medium" }
variable "instance_count"{ default = 2 }

resource "aws_instance" "this" {
  count                  = var.instance_count
  ami                    = "ami-0abcdef1234567890"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]

  tags = { Name = "${var.name}-${count.index}" }
}

output "instance_ids" { value = aws_instance.this[*].id }
output "public_ips"   { value = aws_instance.this[*].public_ip }
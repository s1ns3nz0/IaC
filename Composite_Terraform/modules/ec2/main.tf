# Single responsibility: only creates compute resources

variable "name"       {}
variable "subnet_id"  {}
variable "count"      { default = 1 }

resource "aws_instance" "this" {
  count         = var.count
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
  subnet_id     = var.subnet_id

  tags = { Name = "${var.name}-${count.index}" }
}

# ✅ OUTPUTS
output "instance_ids" { value = aws_instance.this[*].id }
output "public_ips"   { value = aws_instance.this[*].public_ip }
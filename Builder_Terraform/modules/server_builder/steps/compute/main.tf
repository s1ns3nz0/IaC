# Builder step 1: set_instance_type + set_storage
# This step only creates the base compute resource.
# It knows nothing about monitoring or backup.

variable "name"          {}
variable "instance_type" { default = "t3.medium" }
variable "storage_gb"    { default = 20 }
variable "region"        { default = "ap-northeast-2" }
variable "tags"          { default = {} }

resource "aws_instance" "this" {
  ami           = "ami-0abcdef1234567890"
  instance_type = var.instance_type

  root_block_device {
    volume_size = var.storage_gb
  }

  tags = merge({ Name = var.name }, var.tags)
}

output "instance_id"  { value = aws_instance.this.id }
output "instance_arn" { value = aws_instance.this.arn }
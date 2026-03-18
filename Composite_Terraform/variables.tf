# Single responsibility: only creates networking resources
# This is a pure LEAF — it does NOT call any other module

variable "name"       {}
variable "cidr_block" {}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = { Name = var.name }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = "ap-northeast-2a"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# ✅ OUTPUTS — the interface this leaf exposes to its parent
output "vpc_id"    { value = aws_vpc.this.id }
output "subnet_id" { value = aws_subnet.public.id }
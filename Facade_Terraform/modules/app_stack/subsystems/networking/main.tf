# Complex networking subsystem — VPC, subnets, gateways
# The client never touches this directly

variable "name"       {}
variable "cidr_block" {}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = { Name = "${var.name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = "ap-northeast-2a"
  tags              = { Name = "${var.name}-public-subnet" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

output "vpc_id"    { value = aws_vpc.this.id }
output "subnet_id" { value = aws_subnet.public.id }
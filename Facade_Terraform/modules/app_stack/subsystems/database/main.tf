# Database subsystem — RDS with subnet groups
# Client never touches this directly

variable "name"      {}
variable "subnet_id" {}
variable "sg_id"     {}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet"
  subnet_ids = [var.subnet_id]
}

resource "aws_db_instance" "this" {
  identifier           = "${var.name}-db"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.medium"
  db_name              = "appdb"
  username             = "admin"
  password             = "changeme123"
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.sg_id]
  skip_final_snapshot  = true
}

output "db_endpoint" { value = aws_db_instance.this.endpoint }
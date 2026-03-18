# Single responsibility: only creates database resources

variable "name"      {}
variable "subnet_id" {}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = [var.subnet_id]
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = "14"
  instance_class = "db.t3.medium"
  db_name        = "appdb"
  username       = "admin"
  password       = "changeme123"

  db_subnet_group_name = aws_db_subnet_group.this.name
  skip_final_snapshot  = true
}

# ✅ OUTPUTS
output "db_endpoint" { value = aws_db_instance.this.endpoint }
output "db_name"     { value = aws_db_instance.this.db_name }
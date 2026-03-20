# modules/database/main.tf

resource "aws_dynamodb_table" "this" {
  name         = var.table_name       # injected ✅
  billing_mode = var.billing_mode     # injected ✅
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery  # injected ✅
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
  }
}

# VPC Endpoint — uses injected vpc_id
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = var.vpc_id           # injected from networking ✅
  service_name = "com.amazonaws.ap-northeast-2.dynamodb"

  tags = {
    Name        = "vpce-dynamodb-${var.environment}"
    Environment = var.environment
  }
}
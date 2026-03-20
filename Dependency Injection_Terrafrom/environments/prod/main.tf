# environments/prod/main.tf
# Prod orchestrates everything — injects prod-specific values

locals {
  environment = "prod"
  region      = "ap-northeast-2"
}

# ── Step 1: Networking (no dependencies) ─────────────────
module "networking" {
  source = "../../modules/networking"

  environment        = local.environment
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ── Step 2: Database (receives networking outputs) ────────
module "database" {
  source = "../../modules/database"

  environment = local.environment
  table_name  = var.table_name

  # Injecting networking dependencies ✅
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  billing_mode                  = "PAY_PER_REQUEST"
  enable_point_in_time_recovery = true   # always on in prod
}

# ── Step 3: IAM role for Lambda ───────────────────────────
resource "aws_iam_role" "lambda" {
  name = "lambda-role-${local.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:PutItem",
                  "dynamodb:Query", "dynamodb:UpdateItem"]
      Resource = module.database.table_arn  # injected from database module ✅
    }]
  })
}

# ── Step 4: Lambda (receives all dependencies) ────────────
module "order_processor" {
  source = "../../modules/lambda"

  environment   = local.environment
  function_name = var.lambda_function_name

  # Injecting networking ✅
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  # Injecting IAM role ✅
  iam_role_arn = aws_iam_role.lambda.arn

  # Injecting prod-specific environment variables ✅
  environment_variables = {
    TABLE_NAME  = module.database.table_name
    ENVIRONMENT = local.environment
    LOG_LEVEL   = "INFO"
  }

  # Prod-grade settings
  memory_size        = 1024   # generous in prod
  timeout            = 60
  log_retention_days = 90     # long retention in prod
}

# ── Step 5: EKS (receives networking dependencies) ────────
module "eks" {
  source = "../../modules/eks"

  environment  = local.environment
  cluster_name = var.eks_cluster_name

  # Injecting networking ✅
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  # Prod-grade compute settings — injected here
  node_instance_type    = "c6i.xlarge"   # compute-optimized
  desired_node_count    = 6
  min_node_count        = 3
  max_node_count        = 20
  enable_spot_instances = false           # stability over cost in prod
}
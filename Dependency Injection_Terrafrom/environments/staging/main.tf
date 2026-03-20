# environments/staging/main.tf
# Identical structure — different injected values

locals {
  environment = "staging"
  region      = "ap-northeast-2"
}

module "networking" {
  source = "../../modules/networking"

  environment          = local.environment
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "database" {
  source = "../../modules/database"

  environment = local.environment
  table_name  = var.table_name

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  billing_mode                  = "PAY_PER_REQUEST"
  enable_point_in_time_recovery = false  # save cost in staging
}

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

module "order_processor" {
  source = "../../modules/lambda"

  environment   = local.environment
  function_name = var.lambda_function_name

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
  iam_role_arn = aws_iam_role.lambda.arn

  # Staging-specific env vars injected ✅
  environment_variables = {
    TABLE_NAME  = module.database.table_name
    ENVIRONMENT = local.environment
    LOG_LEVEL   = "DEBUG"   # more verbose in staging
  }

  # Cheaper settings for staging
  memory_size        = 512   # smaller
  timeout            = 30
  log_retention_days = 14    # shorter retention
}

module "eks" {
  source = "../../modules/eks"

  environment  = local.environment
  cluster_name = var.eks_cluster_name

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  # Staging — cheaper injected values ✅
  node_instance_type    = "t3.large"  # cheaper than c6i
  desired_node_count    = 2
  min_node_count        = 1
  max_node_count        = 5
  enable_spot_instances = true        # save cost in staging
}
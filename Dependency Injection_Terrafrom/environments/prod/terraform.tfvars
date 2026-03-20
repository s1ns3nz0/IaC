# environments/prod/terraform.tfvars
# All prod-specific dependency values in one place

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
table_name           = "orders-prod"
lambda_function_name = "order-processor-prod"
eks_cluster_name     = "trading-cluster-prod"
# environments/staging/terraform.tfvars
# Staging injects completely different values — same modules ✅

vpc_cidr             = "10.1.0.0/16"   # different CIDR — no clash
availability_zones   = ["ap-northeast-2a", "ap-northeast-2b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
table_name           = "orders-staging"
lambda_function_name = "order-processor-staging"
eks_cluster_name     = "trading-cluster-staging"
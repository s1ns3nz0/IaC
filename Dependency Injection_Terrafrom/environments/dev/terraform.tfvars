# environments/dev/terraform.tfvars
# Dev injects the cheapest possible values ✅

vpc_cidr             = "10.2.0.0/16"
availability_zones   = ["ap-northeast-2a"]  # single AZ — save cost
public_subnet_cidrs  = ["10.2.1.0/24"]
private_subnet_cidrs = ["10.2.11.0/24"]
table_name           = "orders-dev"
lambda_function_name = "order-processor-dev"
eks_cluster_name     = "trading-cluster-dev"
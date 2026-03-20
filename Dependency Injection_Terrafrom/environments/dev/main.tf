# environments/dev/main.tf (only EKS differences shown)

module "eks" {
  source = "../../modules/eks"

  environment  = local.environment
  cluster_name = var.eks_cluster_name

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  # Dev — minimal injected values ✅
  node_instance_type    = "t3.medium"   # smallest
  desired_node_count    = 1             # single node
  min_node_count        = 1
  max_node_count        = 3
  enable_spot_instances = true          # always spot in dev
}
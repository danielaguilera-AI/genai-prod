module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_groups = {
    llm_nodes = {
      name            = "llm-nodes"
      desired_size    = 1
      min_size        = 1
      max_size        = 1
      instance_types  = ["t3.small"]
      capacity_type   = "ON_DEMAND"
      node_role_arn   = aws_iam_role.eks_node_role.arn
      vpc_security_group_ids = [aws_security_group.eks_nodes.id]  # ✅ Attach security group
    }
  }
}

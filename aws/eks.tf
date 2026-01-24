locals {
  cluster_name  = var.cluster_name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 21.0"
  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  subnet_ids      = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets
  vpc_id = module.vpc.vpc_id

  #linking cluster's Service Accounts to AWS IAM Roles, enabling IAM Roles for Service Accounts (IRSA)
  enable_irsa = true
  
  endpoint_private_access = true  #allows your nodes to talk to the API server internally
  endpoint_public_access = true  
  endpoint_public_access_cidrs = [var.endpoint_public_access_cidr]
  
  tags = {
    cluster = "iac"
  }

  eks_managed_node_groups = {
    ng1 = {
      ami_type       = var.ami_type
      instance_types = [var.instance_type]

      min_size     = var.min_size  
      max_size     = var.max_size
      desired_size = var.desired_size
      vpc_security_group_ids = [aws_security_group.ng1_sg.id,module.eks.node_security_group_id]
    }
  }
}




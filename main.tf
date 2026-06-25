# ---------- The private network (VPC) ----------
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "platform-${var.env}"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true # one NAT gateway = cheaper. Fine for learning.
  # These tags let Kubernetes create load balancers later. Leaving them out
  # causes a confusing silent failure, so we add them now.
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
}
# ---------- The Kubernetes cluster (EKS) ----------
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.0"
  cluster_name                   = "platform-${var.env}"
  cluster_version                = "1.33" # a current, stable Kubernetes version
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  # Modern way to grant YOUR user admin access to the cluster:
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"] # small, cheap machines
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}
# ---------- Print useful info after building ----------
output "cluster_name" {
  value = module.eks.cluster_name
}
output "region" {
  value = "us-east-1"
}
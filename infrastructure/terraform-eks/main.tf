data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.2"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Project     = "NutriFlow"
    Environment = "development"
    Terraform   = "true"
  }
}

module "eks" {
  cloudwatch_log_group_retention_in_days = 7
  source                                 = "terraform-aws-modules/eks/aws"
  version                                = "21.26.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = [var.cluster_endpoint_public_access_cidr]

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns = {
      addon_version = "v1.14.7-eksbuild.10"
    }

    eks-pod-identity-agent = {
      addon_version = "v1.3.10-eksbuild.3"

    }

    kube-proxy = {
      addon_version = "v1.36.0-eksbuild.25"
    }

    vpc-cni = {
      addon_version = "v1.22.4-eksbuild.3"

    }
  }

  eks_managed_node_groups = {
    development = {
      name           = "nutriflow-dev-workers"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 1
      desired_size = 1

      labels = {
        Environment = "development"
        Project     = "NutriFlow"
      }
    }
  }

  tags = {
    Project     = "NutriFlow"
    Environment = "development"
    Terraform   = "true"
  }
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "worker_subnet_ids" {
  description = "Public subnets used by the EKS cluster and worker nodes"
  value       = module.vpc.public_subnets
}

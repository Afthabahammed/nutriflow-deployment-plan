variable "aws_region" {
  description = "AWS region for NutriFlow"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "nutriflow-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.36"
}

variable "cluster_endpoint_public_access_cidr" {
  description = "Public IPv4 address allowed to access the EKS API, in CIDR notation"
  type        = string

  validation {
    condition     = can(cidrhost(var.cluster_endpoint_public_access_cidr, 0)) && endswith(var.cluster_endpoint_public_access_cidr, "/32")
    error_message = "Provide one public IPv4 address ending in /32, for example 203.0.113.10/32."
  }
}

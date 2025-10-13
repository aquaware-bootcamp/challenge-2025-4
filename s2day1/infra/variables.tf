variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "bootcamp-eks"
}

variable "repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "bootcamp-repo"
}


output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "region" {
  value = var.region
}


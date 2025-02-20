output "ecr_repository_url" {
  value = aws_ecr_repository.llm_repository[0].repository_url
}

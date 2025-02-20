output "ecr_repository_url" {
  value = try(
    aws_ecr_repository.llm_repository[0].repository_url,
    data.aws_ecr_repository.existing_repository.repository_url,
    "repository-not-found"
  )
}




output "ecr_repository_url" {
  value = coalesce(
    try(data.aws_ecr_repository.existing_repository.repository_url, ""),
    try(aws_ecr_repository.llm_repository[0].repository_url, "")
  )
}




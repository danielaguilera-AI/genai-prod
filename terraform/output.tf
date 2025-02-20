output "ecr_repository_url" {
  value = try(aws_ecr_repository.llm_repository[0].repository_url, "Repository does not exist yet")
}



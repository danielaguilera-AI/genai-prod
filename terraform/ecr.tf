data "aws_ecr_repository" "existing_repository" {
  name = "data-science/llm-deployment"
}

resource "aws_ecr_repository" "llm_repository" {
  count = length(data.aws_ecr_repository.existing_repository.repository_url) > 0 ? 0 : 1
  name  = "data-science/llm-deployment"
}





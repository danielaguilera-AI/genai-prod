# Try to fetch an existing ECR repository
data "aws_ecr_repository" "existing_repository" {
  name = "data-science/llm-deployment"
}

# Create the repository if it does not exist
resource "aws_ecr_repository" "llm_repository" {
  name = "data-science/llm-deployment"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}


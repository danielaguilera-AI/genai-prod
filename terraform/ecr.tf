# Check if the ECR repository already exists
data "aws_ecr_repository" "existing_repository" {
  name = "data-science/llm-deployment"
}

# Create the ECR repository only if it does not exist
resource "aws_ecr_repository" "llm_repository" {
  count = length(data.aws_ecr_repository.existing_repository.id) > 0 ? 0 : 1
  name  = "data-science/llm-deployment"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}

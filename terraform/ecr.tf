resource "aws_ecr_repository" "llm_repository" {
  name = "data-science/llm-deployment"
  force_delete = True
}







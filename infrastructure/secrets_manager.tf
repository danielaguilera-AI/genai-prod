resource "aws_secretsmanager_secret" "github_token" {
  name        = "GITHUB_ACCESS_TOKEN"
  description = "GitHub token for AWS CodeBuild authentication"
}

resource "aws_secretsmanager_secret_version" "github_token_value" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = var.github_token
}

variable "github_token" {}

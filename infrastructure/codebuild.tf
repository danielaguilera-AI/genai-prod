# Retrieve the existing secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "github_token" {
  name = "GITHUB_ACCESS_TOKEN"  # ✅ Reference the existing secret directly
}

# Get the latest version of the secret
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id  # ✅ Use `data` instead of `resource`
}

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  token       = data.aws_secretsmanager_secret_version.github_token.secret_string
  server_type = "GITHUB"
}

resource "aws_codebuild_project" "eks_deploy" {
  name         = "eks-deploy"
  service_role = aws_iam_role.codebuild_role.arn
  build_timeout = "10"

  source {
    type      = "GITHUB"
    location  = "https://github.com/danielaguilera-AI/genai-prod.git"
    git_clone_depth = 1
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"  # ✅ Uses AWS Standard Image with Python 3.11
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  vpc_config {  # ✅ Attach CodeBuild to the EKS VPC
    vpc_id             = module.vpc.vpc_id
    subnets            = module.vpc.private_subnets
    security_group_ids = [aws_security_group.codebuild_sg.id]  # ✅ Create a new security group for CodeBuild
  }
}




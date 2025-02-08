resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-eks-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "eks_deploy" {
  name          = "eks-deploy"
  description   = "Deploys FastAPI to private EKS"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "10"

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/danielaguilera-AI/genai-prod.git"  # 🔹 Replace with your repo
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  vpc_config {
    vpc_id = module.vpc.vpc_id
    subnets = module.vpc.private_subnets
    security_group_ids = [aws_security_group.eks_nodes.id]
  }

  tags = {
    Name = "eks-deploy"
  }
}


# ============================================================
# IAM ROLES AND POLICIES FOR ECS & FASTAPI CONTAINER
# ============================================================

# ------------------------------------------------------------
# 1️⃣ ECS TASK EXECUTION ROLE
# ------------------------------------------------------------
# This role is required for ECS to:
# - Pull Docker images from ECR
# - Send logs to CloudWatch
# - Authenticate with AWS services on behalf of the ECS task

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Amazon-managed policy to the ECS Task Execution Role
# This allows ECS to:
# - Pull images from ECR
# - Write logs to CloudWatch
resource "aws_iam_policy_attachment" "ecs_execution_policy" {
  name       = "ecsExecutionPolicyAttachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------------
# 2️⃣ ECS TASK ROLE (FOR FASTAPI CONTAINER)
# ------------------------------------------------------------
# This role is assumed by the FastAPI application running in the ECS container.
# It allows the container to interact with AWS services like Bedrock.

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# ------------------------------------------------------------
# 3️⃣ CUSTOM POLICY FOR BEDROCK ACCESS
# ------------------------------------------------------------
# This policy allows the FastAPI app inside the ECS container to:
# - Call AWS Bedrock models for text generation.
# - Use "bedrock:InvokeModel" to send prompts and receive responses.

resource "aws_iam_policy" "bedrock_access_policy" {
  name        = "bedrockAccessPolicy"
  description = "Allow ECS task to invoke AWS Bedrock LLM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ]
      Resource = "*"
    }]
  })
}

# Attach the Bedrock access policy to the ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_bedrock" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.bedrock_access_policy.arn
}

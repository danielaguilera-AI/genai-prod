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

resource "aws_iam_policy" "ecs_update_policy" {
  name        = "GitHubActionsECSUpdatePolicy"
  description = "Allows GitHub Actions to update ECS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:ListServices",
          "ecs:ListClusters"
        ]
        Resource = "arn:aws:ecs:us-east-1:180294182444:service/llm-cluster/llm-service"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_ecs_update_policy" {
  name       = "GitHubActionsECSUpdateAttachment"
  policy_arn = aws_iam_policy.ecs_update_policy.arn
  users      = ["ecr-github-actions-user"]  # Replace with your actual IAM user
}

# ============================================================
# ✅ 1️⃣ CREATE API GATEWAY IAM ROLE (WITH FULL TRUST POLICY)
# ============================================================

resource "aws_iam_role" "api_gateway_role" {
  name = "APIGatewayToALBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ============================================================
# ✅ 2️⃣ POLICY: API GATEWAY CAN ACCESS ALB
# ============================================================

resource "aws_iam_policy" "api_gateway_to_alb_policy" {
  name        = "APIGatewayToALBPolicy"
  description = "Allows API Gateway to interact with ALB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================
# ✅ 3️⃣ POLICY: API GATEWAY CAN EXECUTE REQUESTS
# ============================================================

resource "aws_iam_policy" "api_gateway_execution_policy" {
  name        = "APIGatewayExecutionPolicy"
  description = "Allows API Gateway to execute API requests"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "execute-api:Invoke",
          "execute-api:ManageConnections"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================
# ✅ 4️⃣ POLICY: API GATEWAY CAN WRITE LOGS TO CLOUDWATCH
# ============================================================

resource "aws_iam_policy" "api_gateway_logging_policy" {
  name        = "APIGatewayLoggingPolicy"
  description = "Allows API Gateway to send logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# ============================================================
# ✅ 5️⃣ ATTACH POLICIES TO API GATEWAY ROLE
# ============================================================

resource "aws_iam_role_policy_attachment" "attach_api_gateway_alb_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_to_alb_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_api_gateway_execution_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_api_gateway_logging_policy" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_logging_policy.arn
}

# ============================================================
# ✅ 6️⃣ ASSIGN THE IAM ROLE TO API GATEWAY ACCOUNT
# ============================================================

resource "aws_api_gateway_account" "api_gw_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn
}


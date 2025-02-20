# ============================================================
# ECS TASK DEFINITION (FARGATE)
# ============================================================
# Launch Docker containers on AWS = Launch ECS Tasks on ECS Clusters
resource "aws_ecs_task_definition" "llm_task" {
  family                   = "llm-task"
  cpu                      = "512"  # 0.5 vCPU
  memory                   = "1024" # 1 GB RAM
  network_mode             = "awsvpc"  # Required for Fargate
  requires_compatibilities = ["FARGATE"]  # Run in Fargate
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "fastapi-container"
      image     = "${aws_ecr_repository.llm_repository.repository_url}:latest"  # Dynamically retrieve ECR URL
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/llm-task"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


# ============================================================
# CLOUDWATCH LOG GROUP (FOR LOGGING CONTAINER OUTPUTS)
# ============================================================
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/llm-task"
  retention_in_days = 7
}

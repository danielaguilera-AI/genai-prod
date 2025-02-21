resource "aws_ecs_task_definition" "llm_task" {
  family                   = "llm-task"
  cpu                      = "512"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "fastapi-container"
      image = "${try(aws_ecr_repository.llm_repository[0].repository_url)}:latest"
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

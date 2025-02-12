# ============================================================
# SECURITY GROUP FOR ALB (ALLOW PUBLIC TRAFFIC)
# ============================================================

resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  vpc_id      = aws_vpc.main.id  # Uses the main VPC

  # Allow HTTP traffic from anywhere (Public access)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world
  }

  # Allow HTTPS traffic from anywhere (For future HTTPS support)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic to ECS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # ALB must be able to reach ECS
  }
}

# ============================================================
# SECURITY GROUP FOR ECS SERVICE (ONLY ALLOWS ALB TRAFFIC)
# ============================================================

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  vpc_id      = aws_vpc.main.id  # Uses the same VPC

  # Allow outbound requests (ECS must reach external services like AWS Bedrock)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ Correct Way: Separate Security Group Rule to Allow ALB -> ECS Traffic
resource "aws_security_group_rule" "allow_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.alb_sg.id  # ✅ ALB can send requests to ECS
}

# ============================================================
# APPLICATION LOAD BALANCER (ALB)
# ============================================================

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false  # False = Public facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]  # ✅ Uses ALB security group
  subnets           = [aws_subnet.public_1.id, aws_subnet.public_2.id]  # Uses public subnets
}

# ============================================================
# TARGET GROUP FOR ECS SERVICE
# ============================================================

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 8000  # Must match FastAPI container port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# ============================================================
# ALB LISTENER (ROUTES HTTP REQUESTS TO TARGET GROUP)
# ============================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

# ============================================================
# ECS SERVICE - RUNS THE FASTAPI CONTAINER
# ============================================================

resource "aws_ecs_service" "llm_service" {
  name            = "llm-service"
  cluster         = aws_ecs_cluster.llm_cluster.id
  task_definition = aws_ecs_task_definition.llm_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]  # Uses the new public subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  desired_count = 1  # Number of running containers

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "fastapi-container"
    container_port   = 8000
  }
}

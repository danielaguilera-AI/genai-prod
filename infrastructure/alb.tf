resource "aws_lb" "fastapi_alb" {
  name               = "fastapi-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]  # ✅ Now it correctly references `security.tf`
  subnets            = module.vpc.private_subnets
}

resource "aws_lb_target_group" "fastapi_tg" {
  name        = "fastapi-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.fastapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi_tg.arn
  }
}
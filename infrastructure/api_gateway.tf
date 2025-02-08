resource "aws_apigatewayv2_api" "fastapi_api" {
  name          = "FastAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.fastapi_api.id
  name        = "default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "alb_integration" {
  api_id             = aws_apigatewayv2_api.fastapi_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = "http://${aws_lb.fastapi_alb.dns_name}"  # ✅ Use ALB DNS name
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.fastapi_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.alb_integration.id}"
}

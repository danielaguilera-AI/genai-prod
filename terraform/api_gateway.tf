resource "aws_api_gateway_rest_api" "fastapi_api" {
  name        = "fastapi-api"
  description = "REST API for FastAPI backend"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_api.id
  parent_id   = aws_api_gateway_rest_api.fastapi_api.root_resource_id
  path_part   = "generate"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.fastapi_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fastapi_integration" {
  rest_api_id          = aws_api_gateway_rest_api.fastapi_api.id
  resource_id          = aws_api_gateway_resource.proxy.id
  http_method          = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY" # Required for REST API
  type                 = "HTTP_PROXY"
  uri                  = "http://ecs-alb-830296603.us-east-1.elb.amazonaws.com/generate/"
}

resource "aws_api_gateway_deployment" "fastapi_deployment" {
  depends_on  = [aws_api_gateway_integration.fastapi_integration]
  rest_api_id = aws_api_gateway_rest_api.fastapi_api.id
}

resource "aws_api_gateway_stage" "fastapi_stage" {
  deployment_id = aws_api_gateway_deployment.fastapi_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.fastapi_api.id
  stage_name    = "prod"
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.fastapi_stage.invoke_url
}


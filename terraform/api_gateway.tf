# ============================================================
# API GATEWAY - ENTRY POINT FOR THE LLM API
# ============================================================

resource "aws_api_gateway_rest_api" "llm_api" {
  name        = "llm-api-gateway"
  description = "API Gateway for LLM FastAPI"
}

# ============================================================
# RESOURCE - PROXY FOR ALL ROUTES
# ============================================================

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.llm_api.id
  parent_id   = aws_api_gateway_rest_api.llm_api.root_resource_id
  path_part   = "{proxy+}"
}

# ============================================================
# METHOD - ALLOW ALL REQUEST METHODS
# ============================================================

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.llm_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"  # This will change after adding Cognito
}

# ============================================================
# INTEGRATION - CONNECT API GATEWAY TO ALB
# ============================================================

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.llm_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.ecs_alb.dns_name}"
}

# ============================================================
# DEPLOYMENT - CREATE A DEPLOYMENT FOR API GATEWAY
# ============================================================

resource "aws_api_gateway_deployment" "llm_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.llm_api.id
  depends_on  = [aws_api_gateway_integration.proxy_integration]

  triggers = {
    redeployment = timestamp()  # Forces redeployment on every apply
  }
}

# ============================================================
# API STAGE - ENSURE `PROD` STAGE EXISTS
# ============================================================

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.llm_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.llm_api.id
  stage_name    = "prod"
  description   = "Production stage for LLM API"
}



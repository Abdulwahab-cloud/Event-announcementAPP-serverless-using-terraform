resource "aws_api_gateway_rest_api" "Event-Api" {
  name        = "EventsAPI"
  description = "API Gateway for events Application"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "subscribers" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  parent_id   = aws_api_gateway_rest_api.Event-Api.root_resource_id
  path_part   = "subscription"
}

resource "aws_api_gateway_resource" "events" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  parent_id   = aws_api_gateway_rest_api.Event-Api.root_resource_id
  path_part   = "events"
}

# CORS configuration
resource "aws_api_gateway_method" "subscription-options" {
  rest_api_id   = aws_api_gateway_rest_api.Event-Api.id
  resource_id   = aws_api_gateway_resource.subscribers.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "event-options" {
  rest_api_id   = aws_api_gateway_rest_api.Event-Api.id
  resource_id   = aws_api_gateway_resource.events.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "subs-res-options" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.subscribers.id
  http_method = aws_api_gateway_method.subscription-options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "event-res-options" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.event-options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "subs-integration" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.subscribers.id
  http_method = aws_api_gateway_method.subscription-options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "subs-res-integration" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.subscribers.id
  http_method = aws_api_gateway_method.subscription-options.http_method
  status_code = aws_api_gateway_method_response.subs-res-options.status_code
  depends_on = [ aws_api_gateway_integration.subs-integration ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration" "events-integration" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.event-options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration_response" "events-res-integration" {
  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.event-options.http_method
  status_code = aws_api_gateway_method_response.event-res-options.status_code
  depends_on = [ aws_api_gateway_integration.events-integration ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Methods
resource "aws_api_gateway_method" "subs_post" {
  rest_api_id   = aws_api_gateway_rest_api.Event-Api.id
  resource_id   = aws_api_gateway_resource.subscribers.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "events_post" {
  rest_api_id   = aws_api_gateway_rest_api.Event-Api.id
  resource_id   = aws_api_gateway_resource.events.id
  http_method   = "POST"
  authorization = "NONE"
}



# Integrations
resource "aws_api_gateway_integration" "subs-post-integration" {
  rest_api_id             = aws_api_gateway_rest_api.Event-Api.id
  resource_id             = aws_api_gateway_resource.subscribers.id
  http_method             = aws_api_gateway_method.subs_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.subs_invoke_arn
}

resource "aws_api_gateway_integration" "events-post-integration" {
  rest_api_id             = aws_api_gateway_rest_api.Event-Api.id
  resource_id             = aws_api_gateway_resource.events.id
  http_method             = aws_api_gateway_method.events_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.events_invoke_arn
}



# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.subs-integration,
    aws_api_gateway_integration.events-integration
   ]

  rest_api_id = aws_api_gateway_rest_api.Event-Api.id
}

# Stage - Properly connected to deployment
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.Event-Api.id
  stage_name    = "dev"
}


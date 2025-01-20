# Create the REST API
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "This is my API"
}

# # Create a Lambda authorizer
# resource "aws_api_gateway_authorizer" "my_authorizer" {
#   rest_api_id = aws_api_gateway_rest_api.my_api.id
#   name        = "MyLambdaAuthorizer"
#   type        = "TOKEN"
#   authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.my_authorizer.arn}/invocations"
#   identity_source = "method.request.header.Authorization"
# }

# Create a resource
resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "users"
}

# Create a GET method for the resource with authorizer
resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.my_authorizer.id
}

# Create a mock integration
resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.my_resource.id
  http_method = aws_api_gateway_method.my_method.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Create a deployment
resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [
    aws_api_gateway_integration.my_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  description = "Deployment for dev stage"
}

# Create a stage for the deployment
resource "aws_api_gateway_stage" "my_stage" {
  deployment_id = aws_api_gateway_deployment.my_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"
}

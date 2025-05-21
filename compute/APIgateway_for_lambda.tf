resource "aws_api_gateway_rest_api" "unity_api" {
  name        = "unity-api-${var.suffix}"
  description = "REST API for Unity Cloud Integration"
  tags        = var.default_tags
}

# DOCS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer
resource "aws_api_gateway_authorizer" "firebase_authorizer" {
  name                                 = "firebase-authorizer-${var.suffix}"
  rest_api_id                          = aws_api_gateway_rest_api.unity_api.id
  authorizer_uri                       = aws_lambda_function.firebase_authorizer.invoke_arn
  type                                 = "TOKEN"
  identity_source                      = "method.request.header.Authorization"
  # No high rate of traffic is needing support for state file storage; cache interferes with HTTP method changes
  # Cache lowers authorization calls per session but in this case I need support for multiple methods within any time frame
  # If support is ever needed for high frequency calls, make new route(s) not connected to this auth
  authorizer_result_ttl_in_seconds     = 0 
}
###

# Deployment and staging
# Create a new deployment for every apply when manual deploy is enabled
resource "aws_api_gateway_deployment" "unity_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.unity_api.id
  description = local.deployment_description

  depends_on = [
    aws_api_gateway_integration.upload_integration,
    aws_api_gateway_integration.download_integration,
    aws_api_gateway_integration.delete_integration
  ]
}

# Explicit stage resource for more control
resource "aws_api_gateway_stage" "unity_stage" {
  stage_name    = "${var.environment}_${var.suffix}"
  rest_api_id   = aws_api_gateway_rest_api.unity_api.id
  deployment_id = aws_api_gateway_deployment.unity_api_deploy.id
}
###
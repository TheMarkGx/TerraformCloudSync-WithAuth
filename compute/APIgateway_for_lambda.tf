resource "aws_apigatewayv2_api" "unity_api" {
  name          = "unity-api_${var.suffix}"
  protocol_type = "HTTP"
  tags          = var.default_tags
}

# DOCS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_authorizer
resource "aws_apigatewayv2_authorizer" "firebase_authorizer" {
  name             = "firebase-authorizer_${var.suffix}"
  api_id           = aws_apigatewayv2_api.unity_api.id
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.firebase_authorizer.invoke_arn
  identity_sources = ["$request.header.Authorization"]
}


# Using this second integration to dedicate to the handler lambda rather than direct S3 PUT
# Partially modularized here for easier tracing/separation of concerns regarding uploads
resource "aws_apigatewayv2_integration" "general_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.unity_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.unity_s3_url_issuer.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "upload_integration" {
  api_id                 = aws_apigatewayv2_api.unity_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.unity_s3_url_issuer.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

###
###

resource "aws_apigatewayv2_deployment" "unity_api_deploy" {
  api_id = aws_apigatewayv2_api.unity_api.id
  #description = "Force redeploy ${timestamp()}"  # this forces a new deployment, terraform sees this object changed
  depends_on = [ #ensures that API Gateway redeploys only after all routes/integrations
    aws_apigatewayv2_route.upload_route,
    aws_apigatewayv2_route.download_route,
    aws_apigatewayv2_route.delete_route,
    aws_apigatewayv2_integration.general_lambda_integration,
    aws_apigatewayv2_integration.upload_integration
  ]
}

resource "aws_apigatewayv2_stage" "unity_stage" {
  api_id      = aws_apigatewayv2_api.unity_api.id
  name        = "${var.environment}_${var.suffix}"
  auto_deploy = var.api_auto_deploy

  # Only applies if auto_deploy is false, as it would be needed only then
  deployment_id = var.api_auto_deploy ? null : aws_apigatewayv2_deployment.unity_api_deploy.id
}


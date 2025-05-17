resource "aws_apigatewayv2_api" "unity_api" {
  name          = "unity-api"
  protocol_type = "HTTP"
  tags = var.default_tags
}

# Unity has a deep, known problem with consecutive PUT's to pre-signed URLs (works only 1st time)
# Using this second integration to dedicate to the handler lambda rather than direct S3 PUT
# Modularized here for easier tracing/separation of concerns regarding uploads
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

### Routes are split for no reason now other than routing granularity
### To add more make sure handlers are added in unity_s3_url_issuer.py & then compressed into a new .zip, AND new permission block in APIgateway_for_lambda_perms.tf
resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
}

resource "aws_apigatewayv2_route" "download_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "GET /download"
  target    = "integrations/${aws_apigatewayv2_integration.general_lambda_integration .id}"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "DELETE /delete"
  target    = "integrations/${aws_apigatewayv2_integration.general_lambda_integration .id}"
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
  name        = var.environment
  auto_deploy = var.api_auto_deploy

  # Only applies if auto_deploy is false, as it would be needed only then
  deployment_id = var.api_auto_deploy ? null : aws_apigatewayv2_deployment.unity_api_deploy.id
}


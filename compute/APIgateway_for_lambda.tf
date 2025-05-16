resource "aws_apigatewayv2_api" "unity_api" {
  name          = "unity-api"
  protocol_type = "HTTP"
  tags = var.default_tags
}

resource "aws_apigatewayv2_integration" "unity_lambda" {
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
  target    = "integrations/${aws_apigatewayv2_integration.unity_lambda.id}"
}

resource "aws_apigatewayv2_route" "download_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "GET /download"
  target    = "integrations/${aws_apigatewayv2_integration.unity_lambda.id}"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "DELETE /delete"
  target    = "integrations/${aws_apigatewayv2_integration.unity_lambda.id}"
}

###
###

resource "aws_apigatewayv2_stage" "unity_stage" {
  api_id = aws_apigatewayv2_api.unity_api.id
  name   = "$default"
  tags   = var.default_tags
}
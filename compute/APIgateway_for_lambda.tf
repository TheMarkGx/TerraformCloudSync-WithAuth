resource "aws_apigatewayv2_api" "unity_api" {
  name          = "unity-api"
  protocol_type = "HTTP"
  tags          = var.default_tags
}

resource "aws_apigatewayv2_integration" "unity_lambda" {
  api_id                 = aws_apigatewayv2_api.unity_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.unity_s3_url_issuer.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "unity_route" {
  api_id    = aws_apigatewayv2_api.unity_api.id
  route_key = "POST /get-url"
  target    = "integrations/${aws_apigatewayv2_integration.unity_lambda.id}"
}

resource "aws_apigatewayv2_stage" "unity_stage" {
  api_id = aws_apigatewayv2_api.unity_api.id
  name   = "$default"
  tags   = var.default_tags
}

resource "aws_lambda_permission" "allow_apiGateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/POST/get-url"
}

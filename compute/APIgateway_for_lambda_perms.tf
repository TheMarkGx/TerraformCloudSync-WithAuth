# Allow API Gateway (REST) to invoke the backend Lambda
resource "aws_lambda_permission" "allow_apigateway_invoke_backend" {
  statement_id  = "AllowAPIGatewayInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.unity_api.execution_arn}/*/*"
}
# Allow API Gateway (REST) to invoke the authorizer Lambda
resource "aws_lambda_permission" "allow_apigateway_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.firebase_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.unity_api.execution_arn}/authorizers/${aws_api_gateway_authorizer.firebase_authorizer.id}"
}
//resource "aws_lambda_permission" "allow_apiGateway_upload" {
//  statement_id  = "AllowUploadFromAPIGateway"
//  action        = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
//  principal     = "apigateway.amazonaws.com"
//  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/POST/upload"
//}
//
//resource "aws_lambda_permission" "allow_apiGateway_download" {
//  statement_id  = "AllowDownloadFromAPIGateway"
//  action        = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
//  principal     = "apigateway.amazonaws.com"
//  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/GET/download"
//}
//
//resource "aws_lambda_permission" "allow_apiGateway_delete" {
//  statement_id  = "AllowDeleteFromAPIGateway"
//  action        = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
//  principal     = "apigateway.amazonaws.com"
//  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/DELETE/delete"
//}

## HTTP API's do not support the above, only REST API's do. Commented here just in case there's a reason to switch later
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigateway_to_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.firebase_authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/*/authorizers/${aws_apigatewayv2_authorizer.firebase_authorizer.id}"
}


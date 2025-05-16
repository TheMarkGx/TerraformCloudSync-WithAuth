resource "aws_lambda_permission" "allow_apiGateway_upload" {
  statement_id  = "AllowUploadFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/POST/upload"
}

resource "aws_lambda_permission" "allow_apiGateway_download" {
  statement_id  = "AllowDownloadFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/GET/download"
}

resource "aws_lambda_permission" "allow_apiGateway_delete" {
  statement_id  = "AllowDeleteFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unity_s3_url_issuer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.unity_api.execution_arn}/DELETE/delete"
}

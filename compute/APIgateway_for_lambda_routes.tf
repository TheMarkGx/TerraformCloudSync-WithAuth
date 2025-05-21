### Routes are split for no reason now other than routing granularity
### To add more make sure handlers are added in unity_s3_url_issuer.py & then compressed into a new .zip, AND new permission block in APIgateway_for_lambda_perms.tf
#resource "aws_apigatewayv2_route" "upload_route" {
#  api_id    = aws_apigatewayv2_api.unity_api.id
#  route_key = "POST /upload"
#  authorizer_id      = aws_apigatewayv2_authorizer.firebase_authorizer.id
#  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
#  depends_on    = [aws_apigatewayv2_authorizer.firebase_authorizer]
#}
#
#resource "aws_apigatewayv2_route" "download_route" {
#  api_id    = aws_apigatewayv2_api.unity_api.id
#  route_key = "GET /download"
#  authorizer_id      = aws_apigatewayv2_authorizer.firebase_authorizer.id
#  target    = "integrations/${aws_apigatewayv2_integration.general_lambda_integration .id}"
#  depends_on    = [aws_apigatewayv2_authorizer.firebase_authorizer]
#}
#
#resource "aws_apigatewayv2_route" "delete_route" {
#  api_id    = aws_apigatewayv2_api.unity_api.id
#  route_key = "DELETE /delete"
#  authorizer_id      = aws_apigatewayv2_authorizer.firebase_authorizer.id
#  target    = "integrations/${aws_apigatewayv2_integration.general_lambda_integration .id}"
#  depends_on    = [aws_apigatewayv2_authorizer.firebase_authorizer]
#}
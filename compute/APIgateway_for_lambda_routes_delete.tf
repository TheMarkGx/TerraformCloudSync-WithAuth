# Delete path
resource "aws_api_gateway_resource" "delete" {
  rest_api_id = aws_api_gateway_rest_api.unity_api.id
  parent_id   = aws_api_gateway_rest_api.unity_api.root_resource_id
  path_part   = "delete"
}

resource "aws_api_gateway_method" "delete" {
  rest_api_id   = aws_api_gateway_rest_api.unity_api.id
  resource_id   = aws_api_gateway_resource.delete.id
  http_method   = "DELETE"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.firebase_authorizer.id
}

resource "aws_api_gateway_integration" "delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.unity_api.id
  resource_id             = aws_api_gateway_resource.delete.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.unity_s3_url_issuer.invoke_arn
}
###
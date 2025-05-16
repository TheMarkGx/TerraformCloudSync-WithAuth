resource "aws_lambda_function" "unity_s3_url_issuer" {
  function_name = "unity-s3-url-issuer"
  role          = var.lambda_exec_role_arn
  handler       = "unity_s3_url_issuer.main"
  runtime       = "python3.13" 

  filename         = "${path.module}/unity_s3_url_issuer.zip"
  source_code_hash = filebase64sha256("${path.module}/unity_s3_url_issuer.zip")

environment {
  variables = {
    BUCKET_NAME       = var.user_saves_bucket_name
    MAX_S3_VERSIONS   = "10"  # string here, parsed as int in Python - this is for application state file backups, auto removes oldest in the .py file
  }
}

  tags = var.default_tags
}

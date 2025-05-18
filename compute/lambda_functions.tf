resource "aws_lambda_function" "unity_s3_url_issuer" {
  function_name = "unity_s3_url_issuer_${var.suffix}"
  role          = var.lambda_exec_role_arn
  handler       = "unity_s3_url_issuer.main"
  runtime       = var.python_version

  filename         = "${path.module}/unity_s3_url_issuer.zip"
  source_code_hash = filebase64sha256("${path.module}/unity_s3_url_issuer.zip")
  layers           = [aws_lambda_layer_version.dependencies.arn]

  environment { #For the lambda envi
    variables = {
      BUCKET_NAME     = var.user_saves_bucket_name
      MAX_S3_VERSIONS = "10" # string here, parsed as int in Python - this is for application state file backups, auto removes oldest in the .py file
    }
  }

  tags = var.default_tags
}


resource "aws_lambda_function" "firebase_authorizer" {
  function_name = "Firebase_Authorizer_${var.suffix}"
  role          = var.lambda_exec_role_arn
  handler       = "Firebase_Authorizer.main"
  runtime       = var.python_version

  filename         = "${path.module}/firebase_authorizer.zip"
  source_code_hash = filebase64sha256("${path.module}/firebase_authorizer.zip")
  layers           = [aws_lambda_layer_version.dependencies.arn]


  environment {
    variables = {
      USER_SAVES_BUCKET = var.user_saves_bucket_name # Need this to combine with user.id from OAuth
    }
  }

  tags = var.default_tags
}

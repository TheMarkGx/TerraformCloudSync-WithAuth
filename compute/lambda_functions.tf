resource "aws_lambda_function" "unity_s3_url_issuer" {
  function_name = "unity_s3_url_issuer_${var.suffix}"
  role          = var.lambda_exec_role_arn
  handler       = "unity_s3_url_issuer_${var.suffix}.main"
  runtime       = var.python_version

  filename         = "${path.module}/lambda_combined.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_combined.zip")
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
  function_name = "firebase_authorizer_${var.suffix}"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "Firebase_Authorizer.main"
  runtime       = var.python_version

  filename         = "${path.module}/lambda_combined.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_combined.zip")
  layers           = [aws_lambda_layer_version.dependencies.arn]


  environment {
    variables = {
      USER_SAVES_BUCKET = module.storage.user_saves_bucket_name # Need this to combine with user.id from OAuth
    }
  }

  tags = var.default_tags
}

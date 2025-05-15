resource "aws_iam_role" "lambdaExec" {
  name        = "lambdaExec-${var.suffix}"
  description = "Execution role for lambda to set up S3 bucket"

  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]

  tags = var.default_tags

}

data "aws_iam_policy_document" "lambda_assume_role" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambdaExec" {
  name        = "lambdaExec-${var.suffix}"
  description = "Execution role for lambda to set up S3 bucket"

  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.default_tags

}

resource "aws_iam_role_policy_attachment" "lambdaExec_s3" {
  role       = aws_iam_role.lambdaExec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "lambdaExec_logging" {
  role       = aws_iam_role.lambdaExec.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
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

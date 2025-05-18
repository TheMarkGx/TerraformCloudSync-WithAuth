resource "aws_iam_role" "lambda_exec_role" {
  name        = "lambda_exec_role-${var.suffix}"
  description = "Execution role for lambda to set up S3 bucket"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "lambdaExec_s3" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "lambdaExec_logging" {
  role       = aws_iam_role.lambda_exec_role.name
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

resource "aws_iam_policy" "lambda_authorizer_policy" {
  name = "lambda_authorizer_policy-${var.suffix}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.user_saves_bucket_name}/*"
        ]
      }
    ]
  })
  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "lambda_authorizer_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_authorizer_policy.arn
}

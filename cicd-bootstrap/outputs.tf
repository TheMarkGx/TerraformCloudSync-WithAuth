output "aws_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "aws_region" {
  value = var.aws_region
}

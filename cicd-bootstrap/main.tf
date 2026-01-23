terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4" #avoid 6 for now, it just released as a beta a week ago
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# GitHub Actions OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC root CA thumbprint
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Allow main branch deployments AND PR plans.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_owner}/${var.github_repo}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "terraform_deploy" {
  name        = "terraform-deploy"
  description = "Permissions for GitHub Actions to deploy/destroy this Terraform stack."
  policy      = data.aws_iam_policy_document.terraform_deploy.json
}

resource "aws_iam_role_policy_attachment" "terraform_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_deploy.arn
}

data "aws_iam_policy_document" "terraform_deploy" {
  statement {
    sid    = "TerraformReadBasics"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }

  # S3: state + artifacts/buckets managed by this repo
  statement {
    sid    = "S3Management"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["*"]
  }

  # DynamoDB: terraform lock table
  statement {
    sid    = "DynamoDBManagement"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:UpdateTable",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = ["*"]
  }

  # Lambda + API Gateway + Logs
  statement {
    sid    = "LambdaAndAPIGWAndLogs"
    effect = "Allow"
    actions = [
      "lambda:*",
      "apigateway:*",
      "logs:*",
      "cloudwatch:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAMForThisStack"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:ListPolicyVersions",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_owner" {
  type        = string
  description = "GitHub org/user that owns the repo."
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name."
}

variable "role_name" {
  type        = string
  description = "IAM role name assumed by GitHub Actions."
  default     = "github-actions-deploy"
}


variable "aws_region" {
  type        = string
  description = "AWS region for the Terraform backend resources."
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "unity-aws"
}
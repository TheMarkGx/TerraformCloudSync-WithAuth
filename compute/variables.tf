variable "lambda_exec_role_arn" {
  type = string
}

variable "user_saves_bucket_name" {
  type = string
}

variable "default_tags" {
  type = map(string)
}

variable "environment" {
  type = string
}

variable "api_auto_deploy" { #Stage auto-deploy setting
  default = true
}

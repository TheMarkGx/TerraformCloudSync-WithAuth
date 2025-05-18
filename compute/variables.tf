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
  description = "Name of the terraform workspace"
  type = string
}

variable "api_auto_deploy" {
  description = "Stage auto-deploy setting"
  default = true
}

variable "suffix" {
  description = "Random suffix for globally-unique resource names"
  type = string
}

variable "python_version" {
  description = "This is the python version required by all resources and dependencies"
  type = string
}
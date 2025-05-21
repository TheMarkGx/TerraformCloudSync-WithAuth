variable "api_auto_deploy" {
  type        = bool
  description = "If true, API Gateway auto-deploys on change. Good for exclusive Dev workspace"
  default     = false # true for dev, but can be glitchy
}

variable "python_version" {
  type        = string
  description = "This is the python version required by all resources and dependencies"
  default     = "python3.11"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
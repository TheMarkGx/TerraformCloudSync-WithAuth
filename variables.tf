variable "api_auto_deploy" {
  type        = bool
  description = "If true, API Gateway auto-deploys on change. Good for exclusive Dev workspace"
  default     = true  # for dev
}

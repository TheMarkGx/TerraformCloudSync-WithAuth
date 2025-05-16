variable "default_tags" {
  type = map(string)
}

variable "suffix" {
  type = string
}

variable "api_base_url" {
  description = "The public URL of the API Gateway"
  type        = string
}

variable "default_tags" {
  type = map(string)
}

variable "suffix" {
  type = string
}

variable "user_saves_bucket_name" {
  description = "Pulled from storage module"
  type = string
}
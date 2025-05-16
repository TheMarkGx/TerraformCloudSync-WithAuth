output "user_saves_bucket_name" {
  description = "S3 bucket used for Unity save files"
  value = aws_s3_bucket.user_saves.bucket
}

output "public_config_url" {
  value = "https://${aws_s3_bucket.api_registry.bucket}.s3.amazonaws.com/${terraform.workspace}/config.json"
}

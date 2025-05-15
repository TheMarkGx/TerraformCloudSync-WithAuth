output "user_saves_bucket_name" {
  description = "S3 bucket used for Unity save files"
  value = aws_s3_bucket.user_saves.bucket
}

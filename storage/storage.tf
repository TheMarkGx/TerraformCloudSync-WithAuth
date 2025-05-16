###This bucket is the primary data container; access controlled save file bucket
resource "aws_s3_bucket" "user_saves" {
  bucket        = "unity-user-saves-${var.suffix}"
  force_destroy = true

  tags = var.default_tags
}

### This api_registry bucket is the fully *public* file where any production buckets are registered so that the end-user/client can connect here to pull the actual endpoint
### Purpose is to allow for openly scalable multi-environment setups including multi-dev & multi-prod environments (ie legacy application version support)
### Make sure the client GET to the config file @ https://unity-api-registry.s3.amazonaws.com/prod/config.json

resource "aws_s3_bucket" "api_registry" {
  bucket = "unity-api-registry"

  tags = var.default_tags
}

resource "aws_s3_object" "api_config_json" {
  bucket       = aws_s3_bucket.api_registry.bucket
  key          = "${terraform.workspace}/config.json"
  content_type = "application/json"
  acl          = "public-read"

  content = jsonencode({
    api_base_url = var.api_base_url
    upload_path    = "/upload",
    download_path  = "/download"
  })

}

resource "aws_s3_bucket_policy" "public_config_read" {
  bucket = aws_s3_bucket.api_registry.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowPublicRead",
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.api_registry.arn}/*"
    }]
  })
}

### Adding support for versioning/backups for the application state files
resource "aws_s3_bucket_versioning" "user_saves_versioning" {
  bucket = aws_s3_bucket.user_saves.id

  versioning_configuration {
    status = "Enabled"
  }
}

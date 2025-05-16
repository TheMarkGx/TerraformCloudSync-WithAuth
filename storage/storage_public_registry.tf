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

  content = jsonencode({
    api_base_url = "${var.api_base_url}/${var.environment}",
    upload_path    = "/upload",
    download_path  = "/download",
    delete_path    = "/delete"
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

### Registry bucket specifically needs to be truly public as it hosts only a public URL to act as a DNS server for any/all registered terraform workspace deployments
resource "aws_s3_bucket_public_access_block" "api_registry_public_access" {
  bucket = aws_s3_bucket.api_registry.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "api_registry_readonly" {
  bucket = aws_s3_bucket.api_registry.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.api_registry.id}/*"
      }
    ]
  })
}

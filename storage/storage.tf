###This bucket is the primary data container; access controlled save file bucket
resource "aws_s3_bucket" "user_saves" {
  bucket        = "unity-user-saves-${var.suffix}"
  force_destroy = true

  tags = var.default_tags
}

### Adding support for versioning/backups for the application state files
resource "aws_s3_bucket_versioning" "user_saves_versioning" {
  bucket = aws_s3_bucket.user_saves.id

  versioning_configuration {
    status = "Enabled"
  }
}
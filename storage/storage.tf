resource "aws_s3_bucket" "user_saves" {
  bucket        = "unity-user-saves-${var.suffix}"
  force_destroy = true

  tags = var.default_tags
}

output "suffix" {
  value = local.Suffix
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tf_locks.name
}

output "aws_region" {
  value = var.aws_region
}
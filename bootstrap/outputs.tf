output "suffix" {
  value = local.Suffix
}

output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_locks.name
}

output "aws_region" {
  value = var.aws_region
}
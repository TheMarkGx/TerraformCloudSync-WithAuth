
locals {
  Suffix = random_id.suffix.hex

  tfstate_bucket_name = "${var.project_name}-tfstate-${local.Environment}"
  lock_table_name     = "${var.project_name}-tflock-"
  Environment         = terraform.workspace
}
resource "random_id" "suffix" { # Used to manage matching suffixes for all resources unique to its respective deployment, random for now but could concat "dev" or similar later
  count       = var.suffix == null ? 1 : 0
  byte_length = 4
}
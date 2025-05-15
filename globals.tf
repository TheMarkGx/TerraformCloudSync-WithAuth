resource "random_id" "suffix" { # Used to manage matching suffixes for all resources unique to its respective deployment, random for now but could concat "dev" or similar later
  byte_length = 4
}
output "project_suffix" {
  value = "All AWS resources maintained with resource name suffix of ${random_id.suffix.hex}"
}
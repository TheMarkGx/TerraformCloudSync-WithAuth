data "aws_region" "current" {}

locals {
  # helps track just in case there might later be multiple deployments (prod, dev, or support for legacy game/save versions)
  Suffix = random_id.suffix.hex

  default_tags = {
    Name           = "TerraformCloudSaveAPI"
    Environment    = terraform.workspace          # To add a workspace to separate dev/prod deployments, just create the workspace and apply it (but no WS support in Unity proj as of 5/13/25)
    Region         = data.aws_region.current.name # Multi-region support not yet implemented anywhere
    Suffix         = local.Suffix
    ManagedBy      = "Terraform"
    ExecutionPlane = var.execution_plane # This tracks whether the env runs in the optional CICD pipeline or if its a local stack
  }
  Environment = terraform.workspace
}

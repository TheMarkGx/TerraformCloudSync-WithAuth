## https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
## A Lambda layer is a .zip file archive that contains supplementary code or data.
## Layers usually contain library dependencies, a custom runtime, or configuration files.
resource "aws_lambda_layer_version" "dependencies" {
  description         = "Python dependencies used in lambdas"
  filename            = "${path.module}/dependencies.zip"
  layer_name          = "dependencies_${var.suffix}"
  compatible_runtimes = [var.python_version]
  source_code_hash    = filebase64sha256("${path.module}/dependencies.zip")

}

locals { # Needed some data created in a resource added to Var, using locals to merge during deployment prep phase
  default_tags = merge(
    var.default_tags,
    {
      Environment = terraform.workspace  # To add a workspace to separate dev/prod deployments, just create the workspace and apply it (but no WS support in Unity proj as of 5/13/25)
      Suffix      = random_id.suffix.hex # helps track just in case there might later be multiple deployments (prod, dev, or support for legacy game/save versions)
    }
  )
}
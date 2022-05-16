locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.22"
  region          = "eu-west-2"

  tags = {
    Example    = local.name
  }
}
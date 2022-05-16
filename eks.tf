module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18.0"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}

resource "null_resource" "kubectl" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command = "aws eks --region ${local.region} update-kubeconfig --name ${local.name}"
  }
}

resource "null_resource" "fargate_patch_coredns" {
  depends_on = [aws_eks_fargate_profile.default]
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/patch_coredns_deployment.sh"
  }
}

resource "null_resource" "deploy_logging_artifacts" {
  depends_on = [null_resource.fargate_patch_coredns]
  provisioner "local-exec" {
    command = "/bin/bash ./logging/deploy.sh"
  }
}

resource "null_resource" "deploy_guestbook_application" {
  depends_on = [null_resource.deploy_logging_artifacts]
  provisioner "local-exec" {
    command = "/bin/bash ./guestbook-app/deploy.sh"
  }
}

resource "aws_eks_fargate_profile" "default" {
  depends_on             = [module.eks]
  cluster_name           = local.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.eks_fargate_profile_role.arn
  subnet_ids             = flatten([module.vpc.private_subnets])

  selector {
    namespace = "kube-system"
  }

  selector {
    namespace = "default"
  }

}

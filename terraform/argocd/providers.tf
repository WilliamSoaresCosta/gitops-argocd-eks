provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_caller_identity" "current" {}

# O cluster precisa existir antes (esta stack não cria o EKS, só instala coisas nele)
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# O Helm fala com o cluster usando uma role com acesso de admin (access entry).
# O token é gerado na hora pelo aws CLI: nada de kubeconfig ou senha guardada.
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = concat(
        ["eks", "get-token", "--region", var.aws_region, "--cluster-name", var.cluster_name],
        var.eks_admin_role_arn == null ? [] : ["--role-arn", var.eks_admin_role_arn]
      )
    }
  }
}

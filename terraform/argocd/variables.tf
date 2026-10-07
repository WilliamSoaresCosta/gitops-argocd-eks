variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "expected_account_id" {
  description = "ID da conta AWS esperada (trava contra rodar na conta errada)"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "expected_account_id deve ter 12 dígitos."
  }
}

variable "tags" {
  description = "Tags padrão (só valem para recursos AWS; esta stack cria apenas coisas dentro do Kubernetes)"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Nome de um cluster EKS que já existe"
  type        = string
}

variable "eks_admin_role_arn" {
  description = "Role com acesso de admin ao cluster (access entry). null = usa a credencial atual do aws CLI"
  type        = string
  default     = null
}

variable "argocd_chart_version" {
  description = "Versão do chart argo-cd (fixa: atualizar de propósito, nunca sozinho)"
  type        = string
}

variable "argocd_apps_chart_version" {
  description = "Versão do chart argocd-apps (cria projetos e a Application raiz)"
  type        = string
}

variable "gitops_repo_url" {
  description = "Repositório GitOps. Público: URL HTTPS. Privado: URL SSH + deploy key somente leitura (ver README)"
  type        = string

  validation {
    condition     = startswith(var.gitops_repo_url, "https://github.com/") || startswith(var.gitops_repo_url, "git@github.com:")
    error_message = "Use https://github.com/<dono>/<repo>.git (público) ou git@github.com:<dono>/<repo>.git (privado, com deploy key)."
  }
}

variable "gitops_revision" {
  description = "Branch do repositório GitOps que este cluster segue"
  type        = string
  default     = "main"
}

variable "gitops_cluster_path" {
  description = "Pasta com o ponto de entrada do cluster (ApplicationSets)"
  type        = string
  default     = "gitops/clusters/dev"
}

variable "app_namespace_pattern" {
  description = "Namespaces onde os apps podem ser criados (ex.: *-dev)"
  type        = string
  default     = "*-dev"
}

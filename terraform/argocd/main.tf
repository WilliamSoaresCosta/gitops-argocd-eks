# ---------------------------------------------------------------------------
# Argo CD instalado por Helm, com versão fixa.
# Sem Load Balancer: a interface é acessada por port-forward (não cobra e não trava o destroy).
# ---------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  # Espera os pods ficarem prontos antes de seguir para os projetos/apps
  wait    = true
  timeout = 600

  values = [yamlencode({
    dex = {
      enabled = false # sem SSO no laboratório: login com o admin inicial
    }
    configs = {
      cm = {
        # Confere o Git a cada 60s (padrão 120s): deploy aparece mais rápido no laboratório
        "timeout.reconciliation" = "60s"
      }
    }
    server = {
      service = {
        type = "ClusterIP"
      }
    }
  })]
}

# ---------------------------------------------------------------------------
# Projetos e Application raiz (app of apps).
# - projeto "plataforma": só a raiz, que só pode criar ApplicationSets no namespace argocd
# - projeto "apps": os apps, só no repo GitOps e só em namespaces *-dev
# ---------------------------------------------------------------------------
resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version

  depends_on = [helm_release.argocd]

  values = [yamlencode({
    projects = {
      plataforma = {
        namespace   = "argocd"
        description = "Ponto de entrada do cluster: só cria ApplicationSets"
        sourceRepos = [var.gitops_repo_url]
        destinations = [{
          namespace = "argocd"
          server    = "https://kubernetes.default.svc"
        }]
        clusterResourceWhitelist = []
        namespaceResourceWhitelist = [{
          group = "argoproj.io"
          kind  = "ApplicationSet"
        }]
      }
      apps = {
        namespace   = "argocd"
        description = "Aplicações do laboratório"
        sourceRepos = [var.gitops_repo_url]
        destinations = [{
          namespace = var.app_namespace_pattern
          server    = "https://kubernetes.default.svc"
        }]
        # Única coisa fora de namespace que os apps podem criar: o próprio namespace
        clusterResourceWhitelist = [{
          group = ""
          kind  = "Namespace"
        }]
      }
    }

    applications = {
      "root-${var.gitops_revision}" = {
        namespace = "argocd"
        project   = "plataforma"
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = var.gitops_cluster_path
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  })]
}

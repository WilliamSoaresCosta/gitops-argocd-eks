output "argocd_ui" {
  description = "Como abrir a interface do Argo CD"
  value       = "kubectl -n argocd port-forward svc/argocd-server 8080:443  →  https://localhost:8080 (usuário admin)"
}

output "argocd_admin_password_command" {
  description = "Comando (PowerShell) para ver a senha inicial do admin"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | %%{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }"
}

output "argocd_chart_version" {
  description = "Versão do chart instalada"
  value       = helm_release.argocd.version
}

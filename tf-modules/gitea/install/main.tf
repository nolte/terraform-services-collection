resource "kubernetes_namespace" "git_namespace" {
  depends_on = [var.depends_list]
  metadata {
    name = "gitea"
  }
}

data "helm_repository" "nolte" {
  name = "nolte"
  url  = "https://nolte.github.io/helm-charts/"
}

resource "k8sraw_yaml" "gitea_cert" {
  depends_on = [kubernetes_namespace.git_namespace]
  yaml_body  = templatefile("${path.module}/files/certificate.yaml.tpl", { host = var.gitea_ingress_host, namespace = kubernetes_namespace.git_namespace.metadata[0].name })
}

resource "helm_release" "gitea" {
  depends_on = [k8sraw_yaml.gitea_cert]
  name       = "gitea"
  repository = data.helm_repository.nolte.metadata[0].name
  chart      = "gitea"
  version    = "1.10.0"
  namespace  = kubernetes_namespace.git_namespace.metadata[0].name
  values = [
    "${templatefile("${path.module}/files/gitea-chart-values.yml", {
      host     = var.gitea_ingress_host,
      redirect = var.gitea_ingress_redirect,
    })}"
  ]
}

data "kubernetes_secret" "gitea_admin_token" {
  depends_on = [helm_release.gitea, var.depends_list]
  metadata {
    name      = "gitea-admin-token"
    namespace = kubernetes_namespace.git_namespace.metadata[0].name
  }
}
output "gitea_admin_token" {
  value = data.kubernetes_secret.gitea_admin_token.data["token"]

}

variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [helm_release.gitea.id, data.kubernetes_secret.gitea_admin_token]
}

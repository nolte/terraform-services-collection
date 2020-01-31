resource "kubernetes_namespace" "storage_namespace" {
  depends_on = [var.depends_list]
  metadata {
    name = "minio"
  }
}

resource "kubernetes_secret" "minio_admin_credentials" {
  metadata {
    name      = "minio-admin-credentials"
    namespace = kubernetes_namespace.storage_namespace.metadata[0].name
  }

  data = {
    "accesskey" = var.minio_admin_access_key
    "secretkey" = var.minio_admin_secret_key
  }
  type = "Opaque"
}


data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "k8sraw_yaml" "certmanager_cert" {
  yaml_body = templatefile("${path.module}/files/certificate.yaml.tpl", { ingress_hosts = var.minio_ingress_host, namespace = kubernetes_namespace.storage_namespace.metadata[0].name })
}

resource "helm_release" "minio" {
  name       = "minio"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "minio"
  namespace  = kubernetes_namespace.storage_namespace.metadata[0].name
  values = [
    "${templatefile("${path.module}/files/minio-chart-values.yml.tpl", {
      ingress_hosts            = var.minio_ingress_host,
      persistence_storageClass = var.minio_persistence_storageClass,
      persistence_size         = var.minio_persistence_size,
      redirect                 = var.minio_ingress_redirect,
    })}"
  ]

  set {
    name  = "existingSecret"
    value = kubernetes_secret.minio_admin_credentials.metadata[0].name
  }

}


variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [helm_release.minio.id]
}


output "admin_access_key" {
  # list all resources in this module here so that other modules are able to depend on this
  value = var.minio_admin_access_key
}
output "admin_secret_key" {
  # list all resources in this module here so that other modules are able to depend on this
  value = var.minio_admin_secret_key
}

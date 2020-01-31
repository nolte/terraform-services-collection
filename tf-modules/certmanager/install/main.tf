resource "kubernetes_namespace" "certmanager" {
  depends_on = [var.depends_list]

  metadata {
    name = "cert-manager"
  }
}


resource "k8sraw_yaml" "certmanager_crds" {
  depends_on = [kubernetes_namespace.certmanager]
  yaml_body  = file("${path.module}/files/00-crds.yaml")
}

data "helm_repository" "jetstack" {

  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "certmanager" {
  depends_on = [k8sraw_yaml.certmanager_crds]

  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.certmanager.metadata[0].name
  values = [
    "${file("${path.module}/files/values.yml")}"
  ]

}


resource "k8sraw_yaml" "certmanager_issuer_selfsigned" {
  depends_on = [helm_release.certmanager]
  count      = var.issuer_selfsigned_enabled ? 1 : 0
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: ${var.issuer_name}
spec:
  selfSigned: {}
  YAML
}

resource "k8sraw_yaml" "certmanager_issuer_letsencrypt" {
  depends_on = [helm_release.certmanager]
  count      = var.issuer_letsencrypt_enabled ? 1 : 0
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: ${var.issuer_name}
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${var.issuer_letsencrypt_email}
    server: ${lookup(var.issuer_letsencrypt_server, var.issuer_letsencrypt, "")}
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: ${lookup(var.issuer_letsencrypt_secret, var.issuer_letsencrypt, "")}
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: traefik
  YAML
}

variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [helm_release.certmanager.id]
}

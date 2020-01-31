

data "helm_repository" "nolte" {
  count = var.enabled ? 1 : 0
  name  = "nolte"
  url   = "https://nolte.github.io/helm-charts/"
}



resource "helm_release" "csi_hcloud" {
  count      = var.enabled ? 1 : 0
  depends_on = [var.depends_list]
  name       = "csi-hcloud"
  repository = element(data.helm_repository.nolte.*.metadata[0].name, count.index)
  chart      = "csi-hcloud"
  namespace  = "kube-system"

  set {
    name  = "token"
    value = var.hcloud_csi_token
  }
}

variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = element(concat(helm_release.csi_hcloud.*.id, [""]), 0)
}

resource "kubernetes_namespace" "backup_namespace" {
  depends_on = [var.depends_list]
  metadata {
    name = "stash"
  }
}

resource "minio_iam_user" "minio_backup_user" {
  name          = "stash"
  force_destroy = true

  tags = {
    provider = "k8s"
    service  = "backup"
  }
}

resource "kubernetes_secret" "stash_s3_credentials" {
  metadata {
    name      = "backup-s3"
    namespace = kubernetes_namespace.backup_namespace.metadata[0].name
  }

  data = {
    "AWS_ACCESS_KEY_ID"     = minio_iam_user.minio_backup_user.name
    "AWS_SECRET_ACCESS_KEY" = minio_iam_user.minio_backup_user.secret
  }
  type = "Opaque"
}


#resource "minio_iam_user_policy_attachment" "minio_backup_user_policy" {
#  policy_name = "stash-backups"
#  user_name   = minio_iam_user.minio_backup_user.name
#}

variable "minio_stash_backup_group_name" {
  default = "stash-backups"
}

resource "minio_iam_group_membership" "stash-backupusers" {
  name = "tf-stash-backupusers-membership"

  users = [
    "${minio_iam_user.minio_backup_user.name}"
  ]

  group = var.minio_stash_backup_group_name
}

data "helm_repository" "appscode" {
  name = "appscode"
  url  = "https://charts.appscode.com/stable/"
}

resource "helm_release" "stash" {
  name       = "stash"
  repository = data.helm_repository.appscode.metadata[0].name
  chart      = "stash"
  namespace  = kubernetes_namespace.backup_namespace.metadata[0].name
  values = [
    "${file("${path.module}/files/stash-chart-values.yml")}"
  ]
  version = "v0.9.0-rc.4"
}


variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [helm_release.stash.id]
}


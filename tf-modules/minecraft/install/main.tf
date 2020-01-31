
variable "backup_bucket_name" {
  default = "stash-backup"
}

variable "s3_backup_endpoint" {
  default = "http://minio.minio.svc:9000"
}

resource "kubernetes_namespace" "minecraft_namespace" {
  depends_on = [var.depends_list]
  metadata {
    name = "minecraft"
  }
}

variable "minecraft_volume_size" {
  default = "10Gi"
}

data "helm_repository" "nolte" {
  name = "nolte"
  url  = "https://nolte.github.io/helm-charts/"
}

resource "kubernetes_persistent_volume_claim" "minecraft" {

  metadata {
    name      = "minecraft-pvc"
    namespace = kubernetes_namespace.minecraft_namespace.metadata[0].name
    annotations = {
      "stash.appscode.com/backup-blueprint" : "mc-backup-blueprint"
    }
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.minecraft_volume_size
      }
    }
  }
}

locals {
  STASH_REPO_NAME = "mc-restore-repo"
}

resource "k8sraw_yaml" "stash_mc_backup_repo" {
  count     = 0
  yaml_body = <<YAML
apiVersion: stash.appscode.com/v1alpha1
kind: Repository
metadata:
  name: ${local.STASH_REPO_NAME}
  namespace: ${kubernetes_namespace.minecraft_namespace.metadata[0].name}
spec:
  backend:
    s3:
      endpoint: ${var.s3_backup_endpoint} # use server URL for s3 compatible other storage service
      bucket: ${var.backup_bucket_name}
      prefix: k8s/pvc/minecraft/persistentvolumeclaim/minecraft-minecraft-datadir
    storageSecretName: ${kubernetes_secret.mc_stash_backup_credentials.metadata[0].name}
  wipeOut: false
    YAML
}

resource "k8sraw_yaml" "stash_mc_backup_recovery" {
  count     = 0
  yaml_body = <<YAML
apiVersion: stash.appscode.com/v1beta1
kind: RestoreSession
metadata:
  name: restore-mc
  namespace: ${kubernetes_namespace.minecraft_namespace.metadata[0].name}
spec:
  task:
    name: pvc-restore
  repository:
    name: ${local.STASH_REPO_NAME}
  target:
    ref:
      apiVersion: v1
      kind: PersistentVolumeClaim
      name: ${kubernetes_persistent_volume_claim.minecraft.metadata[0].name}
  rules:
  - snapshots: ["latest"]
    YAML
}

resource "helm_release" "minecraft" {
  depend_on  = [kubernetes_persistent_volume_claim.minecraft]
  name       = "minecraft"
  repository = data.helm_repository.nolte.metadata[0].name
  chart      = "minecraft"
  namespace  = kubernetes_namespace.minecraft_namespace.metadata[0].name
  values = [
    "${file("${path.module}/files/minecraft-chart-values.yml")}"
  ]

  set {
    name  = "persistence.dataDir.existing"
    value = kubernetes_persistent_volume_claim.minecraft.metadata[0].name
  }

  set {
    name  = "persistence.dataDir.Size"
    value = var.minecraft_volume_size
  }
  set {
    name  = "minecraftServer.rcon.password"
    value = "CHANGEME!"
  }
  set {
    name  = "minecraftServer.nodePort"
    value = 30972
  }
}

resource "minio_iam_user" "minio_backup_user" {
  name          = "minecraft"
  force_destroy = true

  tags = {
    provider = "k8s"
    service  = "backup"
  }
}

variable "minio_stash_backup_group_name" {
  default = "stash-backups"
}

resource "minio_iam_group_membership" "stash-backupusers" {
  name = "tf-stash-minecraft-backupusers-membership"

  users = [
    "${minio_iam_user.minio_backup_user.name}"
  ]

  group = var.minio_stash_backup_group_name
}


resource "kubernetes_secret" "mc_stash_backup_credentials" {
  metadata {
    name      = "stash-credentials-cfg"
    namespace = kubernetes_namespace.minecraft_namespace.metadata[0].name
  }

  data = {
    AWS_ACCESS_KEY_ID     = minio_iam_user.minio_backup_user.name
    AWS_SECRET_ACCESS_KEY = minio_iam_user.minio_backup_user.secret
    RESTIC_PASSWORD       = "changeme"
  }

  type = "Opaque"
}

resource "k8sraw_yaml" "stash_blueprint" {
  yaml_body = <<YAML
apiVersion: stash.appscode.com/v1beta1
kind: BackupBlueprint
metadata:
  name: mc-backup-blueprint
  namespace: ${kubernetes_namespace.minecraft_namespace.metadata[0].name}
spec:
  # ============== Blueprint for Repository ==========================
  backend:
    s3:
      endpoint: ${var.s3_backup_endpoint} # use server URL for s3 compatible other storage service
      bucket: ${var.backup_bucket_name}
      prefix: /k8s/pvc/$${TARGET_NAMESPACE}/$${TARGET_KIND}/$${TARGET_NAME}
    storageSecretName: ${kubernetes_secret.mc_stash_backup_credentials.metadata[0].name}
  # ============== Blueprint for BackupConfiguration =================
  task:
    name: pvc-backup
  schedule: "*/15 * * * *"
  retentionPolicy:
    name: 'keep-last-5'
    keepLast: 2
    keepHourly: 4
    keepDaily: 10
    keepWeekly: 9
    keepMonthly: 3
    keepYearly: 10    
    prune: true
    YAML
}


variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [helm_release.minecraft.id]
}

locals {
  backup_bucket_name        = "stash-backup"
  backup_bucket_policy_name = "stash-backups"
  s3_backup_endpoint        = "http://minio.minio.svc:9000"
}

resource "kubernetes_namespace" "minecraft_namespace" {
  metadata {
    name = "minecraft"
  }
}

data "helm_repository" "nolte" {
  name = "nolte"
  url  = "https://nolte.github.io/helm-charts/"
}

resource "kubernetes_persistent_volume_claim" "minecraft" {

  metadata {
    name      = "minecraft-pvc"
    namespace = kubernetes_namespace.minecraft_namespace.metadata[0].name
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
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
      endpoint: ${local.s3_backup_endpoint} # use server URL for s3 compatible other storage service
      bucket: ${local.backup_bucket_name}
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
  name       = "minecraft"
  repository = data.helm_repository.nolte.metadata[0].name
  chart      = "minecraft"
  namespace  = kubernetes_namespace.minecraft_namespace.metadata[0].name
  values = [
    "${file("files/minecraft-chart-values.yml")}"
  ]

  set {
    name  = "persistence.dataDir.existing"
    value = kubernetes_persistent_volume_claim.minecraft.metadata[0].name
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

resource "minio_iam_user_policy_attachment" "minio_backup_user_policy" {
  policy_name = local.backup_bucket_policy_name
  user_name   = minio_iam_user.minio_backup_user.name
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
      endpoint: ${local.s3_backup_endpoint} # use server URL for s3 compatible other storage service
      bucket: ${local.backup_bucket_name}
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

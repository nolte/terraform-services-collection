resource "kubernetes_namespace" "backup_namespace" {
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

resource "minio_s3_bucket" "minio_backup_bucket" {
  bucket = "stash-backup"
  acl    = "private"
}

resource "minio_iam_policy" "minio_backup_user_policy" {
  name   = "stash-backups"
  policy = <<EOF
{
     "Version": "2012-10-17",
     "Statement": [
         {
             "Effect": "Allow",
             "Action": [
                 "s3:GetObject",
                 "s3:DeleteObject",
                 "s3:PutObject",
                 "s3:AbortMultipartUpload",
                 "s3:ListMultipartUploadParts"
             ],
             "Resource": [
                 "arn:aws:s3:::${minio_s3_bucket.minio_backup_bucket.bucket}/*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "s3:ListBucket"
             ],
             "Resource": [
                 "arn:aws:s3:::${minio_s3_bucket.minio_backup_bucket.bucket}"
             ]
         }
     ]
 }
EOF
}

resource "minio_iam_user_policy_attachment" "minio_backup_user_policy" {
  policy_name = minio_iam_policy.minio_backup_user_policy.name
  user_name   = minio_iam_user.minio_backup_user.name
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
    "${file("files/stash-chart-values.yml")}"
  ]
  version = "v0.9.0-rc.4"

  # set {
  #   name  = "credentials.existingSecret"
  #   value = kubernetes_secret.stash_k8s_credentials.metadata[0].name
  # }
  # set {
  #   name  = "configuration.backupStorageLocation.bucket"
  #   value = minio_s3_bucket.minio_backup_bucket.bucket
  # }
}

resource "kubernetes_secret" "stash_k8s_credentials" {
  metadata {
    name      = "velero-cfg"
    namespace = kubernetes_namespace.backup_namespace.metadata[0].name
  }

  data = {
    cloud = <<EOF
[default]
aws_access_key_id: ${minio_iam_user.minio_backup_user.name}
aws_secret_access_key: ${minio_iam_user.minio_backup_user.secret}
EOF 
  }

  type = "Opaque"
}

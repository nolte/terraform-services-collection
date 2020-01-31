

resource "minio_s3_bucket" "minio_backup_bucket" {
  depends_on = [var.depends_list]
  bucket     = "backups"
  acl        = "private"
}

resource "minio_iam_policy" "minio_backup_bucket_policy" {
  depends_on = [minio_s3_bucket.minio_backup_bucket]
  name       = "backups"
  policy     = <<EOF
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

resource "minio_iam_group" "backup_users" {
  name       = "backup-users"
  depends_on = [minio_iam_policy.minio_backup_bucket_policy]
}

resource "minio_iam_group_policy_attachment" "minio_backup_user_group_policy" {
  depends_on  = [minio_iam_group.backup_users, minio_iam_policy.minio_backup_bucket_policy]
  group_name  = minio_iam_group.backup_users.name
  policy_name = minio_iam_policy.minio_backup_bucket_policy.name
}

variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [minio_s3_bucket.minio_backup_bucket.id]
}

output "backup_bucket_policy" {
  value = minio_iam_policy.minio_backup_bucket_policy.name
}

output "backup_bucket_name" {
  value = minio_s3_bucket.minio_backup_bucket.bucket
}

output "backup_user_group_name" {
  value = minio_iam_group.backup_users.name
}

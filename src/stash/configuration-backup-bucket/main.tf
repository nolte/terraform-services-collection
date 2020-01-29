resource "minio_s3_bucket" "minio_backup_bucket" {
  bucket = "stash-backup"
  acl    = "private"
}

resource "minio_iam_group" "minio_backup_user_group" {
  name          = "stash-backups"
  force_destroy = true
}

resource "minio_iam_group_policy_attachment" "minio_backup_user_group_policy" {
  group_name  = minio_iam_group.minio_backup_user_group.name
  policy_name = minio_iam_policy.minio_backup_user_policy.name
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


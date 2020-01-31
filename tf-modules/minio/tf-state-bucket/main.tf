



resource "minio_s3_bucket" "minio_tf_state_bucket" {
  depends_on = [var.depends_list]
  bucket     = var.minio_tf_state_bucket_name
  acl        = "private"
}

resource "minio_iam_policy" "minio_tf_state_bucket_policy" {
  depends_on = [minio_s3_bucket.minio_tf_state_bucket]
  name       = var.minio_tf_state_bucket_policy_name
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
                 "arn:aws:s3:::${minio_s3_bucket.minio_tf_state_bucket.bucket}/*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": [
                 "s3:ListBucket"
             ],
             "Resource": [
                 "arn:aws:s3:::${minio_s3_bucket.minio_tf_state_bucket.bucket}"
             ]
         }
     ]
}
EOF
}

resource "minio_iam_group" "state_file_users" {
  name       = var.state_file_users_group_name
  depends_on = [minio_iam_policy.minio_tf_state_bucket_policy]
}

resource "minio_iam_group_policy_attachment" "minio_tf_state_file_policy" {
  depends_on  = [minio_iam_group.state_file_users, minio_iam_policy.minio_tf_state_bucket_policy]
  group_name  = minio_iam_group.state_file_users.name
  policy_name = minio_iam_policy.minio_tf_state_bucket_policy.name
}

variable "depends_list" {
  default = []
}

output "depend_on" {
  # list all resources in this module here so that other modules are able to depend on this
  value = [minio_s3_bucket.minio_tf_state_bucket.id]
}

output "tf_state_user_group_name" {
  value = minio_iam_group.state_file_users.name
}

output "tf_state_bucket_name" {
  value = minio_s3_bucket.minio_tf_state_bucket.id
}

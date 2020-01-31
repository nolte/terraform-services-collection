# Minecraft

## Precondition

* **Remote State File** Bucket (like [storage_node](../storage_node))


## Usage

```bash

terraform apply --var "hcloud_csi_token=$(pass internet/hetzner.com/projects/personal_storage/k8s-csi-token)"

```

```bash

export AWS_S3_ENDPOINT=http://minio.172-17-177-11.sslip.io \
    && export AWS_ACCESS_KEY_ID=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.accesskey' | base64 -d) \
    && export AWS_SECRET_ACCESS_KEY=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.secretkey' | base64 -d) \
    && export MINIO_ENDPOINT=minio.172-17-177-11.sslip.io \
    && export MINIO_ACCESS_KEY=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.accesskey' | base64 -d) \
    && export MINIO_SECRET_KEY=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.secretkey' | base64 -d)

```
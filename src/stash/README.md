# Stash

Configure a [stash.run](https://stash.run) Backup Operator, and configure relevant base.




## Usage

The Terraform State will be handle as s3 **Remote State** file.

```bash
export HCLOUD_TOKEN_STORAGE_PROJECT=$(pass internet/hetzner.com/projects/personal_storage/token) && \
   export HCLOUD_TOKEN=$(pass internet/hetzner.com/projects/minecraft/terraform-token) && \
   export AWS_ACCESS_KEY_ID=$(pass internet/project/mystoragebox/minio_access_key) && \
   export AWS_SECRET_ACCESS_KEY=$(pass internet/project/mystoragebox/minio_secret_key) && \
   export AWS_S3_ENDPOINT=https://$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storagenode' | jq -r '.servers[0].public_net.ipv4.dns_ptr') && \
   export MINIO_ACCESS_KEY=$(pass internet/project/mystoragebox/minio_access_key) && \
   export MINIO_SECRET_KEY=$(pass internet/project/mystoragebox/minio_secret_key) && \
   export MINIO_ENDPOINT=$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storagenode' | jq -r '.servers[0].public_net.ipv4.dns_ptr')
```

```bash
export HCLOUD_TOKEN_STORAGE_PROJECT=$(pass internet/hetzner.com/projects/personal_storage/token) && \
   export HCLOUD_TOKEN=$(pass internet/hetzner.com/projects/minecraft/terraform-token) && \
   export AWS_ACCESS_KEY_ID=$(pass internet/project/mystoragebox/minio_access_key) && \
   export AWS_SECRET_ACCESS_KEY=$(pass internet/project/mystoragebox/minio_secret_key) && \
   export AWS_S3_ENDPOINT=https://$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storagenode' | jq -r '.servers[0].public_net.ipv4.dns_ptr') && \
   export MINIO_ACCESS_KEY=$(pass internet/project/mystoragebox/minio_access_key) && \
   export MINIO_SECRET_KEY=$(pass internet/project/mystoragebox/minio_secret_key) && \
   export MINIO_ENDPOINT=$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storagenode' | jq -r '.servers[0].public_net.ipv4.dns_ptr')
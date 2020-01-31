

```bash
export AWS_S3_ENDPOINT=http://minio.172-17-177-11.sslip.io \
    && export AWS_ACCESS_KEY_ID=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.accesskey' | base64 -d) \
    && export AWS_SECRET_ACCESS_KEY=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.secretkey' | base64 -d) 
```

```bash

 export HCLOUD_TOKEN_STORAGE_PROJECT=$(pass internet/hetzner.com/projects/personal_storage/token)

terraform apply \
    --var "buckets_source_access_key=$(pass internet/project/mystoragebox/minio_access_key)" \
    --var "buckets_source_secret_key=$(pass internet/project/mystoragebox/minio_secret_key)" \
    --var "buckets_source_endpoint=https://$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storagenode' | jq -r '.servers[0].public_net.ipv4.dns_ptr')" \
    --var "buckets_target_access_key=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.accesskey' | base64 -d)" \
    --var "buckets_target_secret_key=$(kubectl -n minio get secret minio-admin-credentials -ojson | jq -r '.data.secretkey' | base64 -d)" \
    --var "buckets_target_endpoint=http://minio.minio.svc:9000" 
```
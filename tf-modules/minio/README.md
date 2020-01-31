# Minio Object Storage

```
kubectl -n minio port-forward svc/minio 9000
```

#### MC Client

```bash
export MINIO_ENDPOINT=$(curl -s -H "Authorization: Bearer $HCLOUD_TOKEN_STORAGE_PROJECT" 'https://api.hetzner.cloud/v1/servers?name=storage-k3s' | jq -r '.servers[0].public_net.ipv4.dns_ptr') \
&& mc config host add miniok3s \
    https://$MINIO_ENDPOINT \
    $(pass internet/project/mystoragebox/minio_access_key) \
    $(pass internet/project/mystoragebox/minio_secret_key) 
```
---
# Original https://github.com/helm/charts/blob/master/stable/minio/values.yaml
replicas: 1
ingress:
  enabled: false
buckets: []
metrics:
  # Metrics can not be disabled yet: https://github.com/minio/minio/issues/7493
  serviceMonitor:
    enabled: false
environment:
  MINIO_PROMETHEUS_AUTH_TYPE: "public"

persistence:
  enabled: true
  storageClass: ${persistence_storageClass}
  VolumeName: ""
  accessMode: ReadWriteOnce
  size: ${persistence_size}

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/frontend-entry-points: http,https
    %{ if redirect }traefik.ingress.kubernetes.io/redirect-entry-point: https%{ endif ~}
    # cert-manager.io/cluster-issuer: "cluster-issuer"
  path: /
  hosts:
%{ for host in ingress_hosts ~}    
    - ${host}
%{ endfor ~}
  paths:
    - / 
  tls:
    - secretName: minio-cert-secret
      hosts:
%{ for host in ingress_hosts ~}       
       - ${host}
%{ endfor ~}
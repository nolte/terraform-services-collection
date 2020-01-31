---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: "minio-cert"
  namespace: "${ namespace }"
spec:
  secretName: "minio-cert-secret"
  dnsNames:
%{ for host in ingress_hosts ~}   
  - ${host}
%{ endfor ~}       
  issuerRef:
    name: "cluster-issuer"
    kind: ClusterIssuer